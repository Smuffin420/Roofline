extends Node

signal peer_ready(id: int)
signal join_accepted
signal join_denied
signal need_password(room_name: String)

const PORT := 7777
const LOBBY := 10
const DISCOVERY := 7778
const Board := preload("res://scripts/board.gd")

var peer: ENetMultiplayerPeer
var notice := ""
var join_address := ""
var room_name := ""
var room_password := ""
var password_try := ""
var accepted := {}
var rooms := {}
var hosting := false
var browsing := false
var _awaiting := false
var _beacon: PacketPeerUDP
var _listen: PacketPeerUDP
var _beacon_wait := 0.0
var _tailscale_ip := ""
var _tailscale_peers := PackedStringArray()
var _tailscale_wait := 0.0
var _tailscale_path_checked := false


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer)
	multiplayer.peer_disconnected.connect(_on_peer_left)
	multiplayer.connection_failed.connect(_on_failed)
	multiplayer.server_disconnected.connect(_on_dropped)


func _process(delta: float) -> void:
	if hosting:
		_tailscale_wait += delta
		if _tailscale_wait >= 4.0:
			_tailscale_wait = 0.0
			_refresh_tailscale()
		_beacon_wait += delta
		if _beacon_wait >= 0.5:
			_beacon_wait = 0.0
			_shout()
	if browsing:
		_hear()
		_expire(delta)


func host_game(named: String, secret: String) -> Error:
	offline()
	room_name = _clean_room(named)
	room_password = secret.strip_edges()
	if room_password.length() > 24:
		room_password = room_password.substr(0, 24)
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_server(PORT, LOBBY - 1)
	if err != OK:
		peer = null
		room_name = ""
		room_password = ""
		return err
	multiplayer.multiplayer_peer = peer
	hosting = true
	_open_beacon()
	_refresh_tailscale()
	return OK


func join_game(ip: String, secret: String) -> Error:
	offline()
	password_try = secret.strip_edges()
	join_address = ip
	_awaiting = true
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, PORT)
	if err != OK:
		peer = null
		join_address = ""
		password_try = ""
		_awaiting = false
		return err
	multiplayer.multiplayer_peer = peer
	return OK


func send_password(secret: String) -> void:
	password_try = secret.strip_edges()
	_awaiting = true
	submit_password.rpc_id(1, password_try)


func cancel_join() -> void:
	_awaiting = false
	if hosting:
		return
	if peer != null:
		offline()


func start_browse() -> Error:
	browsing = true
	if _listen != null:
		return OK
	_listen = PacketPeerUDP.new()
	var err := _listen.bind(DISCOVERY)
	if err != OK:
		_listen = null
		browsing = false
		return err
	_listen.set_broadcast_enabled(true)
	return OK


func stop_browse() -> void:
	browsing = false
	rooms.clear()
	if _listen != null:
		_listen.close()
		_listen = null


func offline() -> void:
	_awaiting = false
	hosting = false
	_close_beacon()
	accepted.clear()
	room_name = ""
	room_password = ""
	password_try = ""
	_tailscale_ip = ""
	_tailscale_peers = PackedStringArray()
	_tailscale_wait = 0.0
	if peer != null:
		peer.close()
		peer = null
	multiplayer.multiplayer_peer = null
	join_address = ""


func is_online() -> bool:
	return peer != null


func connected() -> bool:
	return peer != null and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED


func tailscale_address() -> String:
	if _tailscale_ip != "":
		return _tailscale_ip
	return _local_tailscale_address()


func host_reach_line() -> String:
	var line := "On this Wi-Fi it shows up in Join, or use %s. Port %d." % [lan_hint(), PORT]
	var ts := tailscale_address()
	if ts != "":
		return line + " Tailscale friends see it in Join, or use %s." % ts
	return line + " For another house, install Tailscale on both computers, sign in, and host again."


func lan_hint() -> String:
	var best := ""
	var rank := 99
	for address in IP.get_local_addresses():
		var score := _rank_ip(str(address))
		if score < rank:
			rank = score
			best = str(address)
	if best == "":
		return "this computer's IPv4 address"
	return best


func listed_rooms() -> Array:
	var physical := {}
	var any_other := {}
	for ip in rooms.keys():
		var text := str(ip)
		var named := str(rooms[ip]["name"])
		if not text.begins_with("127."):
			any_other[named] = true
		if not text.begins_with("127.") and not _is_tailscale_ip(text):
			physical[named] = true
	var list: Array = []
	for ip in rooms.keys():
		var text := str(ip)
		var named := str(rooms[ip]["name"])
		if text.begins_with("127.") and any_other.has(named):
			continue
		if _is_tailscale_ip(text) and physical.has(named):
			continue
		list.append({
			"ip": str(ip),
			"name": named,
			"locked": bool(rooms[ip]["locked"]),
		})
	list.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a["name"]) < str(b["name"]))
	return list


func room_stamp() -> String:
	var lines: PackedStringArray = []
	for room in listed_rooms():
		lines.append("%s|%s|%s" % [str(room["ip"]), str(room["name"]), str(room["locked"])])
	return "\n".join(lines)


func _on_peer(id: int) -> void:
	if peer == null or multiplayer.get_unique_id() != 1:
		return
	describe.rpc_id(id, room_name, room_password != "")


func _on_peer_left(id: int) -> void:
	accepted.erase(id)


func _on_failed() -> void:
	if not _awaiting:
		return
	_awaiting = false
	notice = "Couldn't reach that room."
	join_denied.emit()


func _on_dropped() -> void:
	if not _awaiting:
		return
	_awaiting = false
	if notice == "":
		if password_try != "":
			notice = "Wrong password."
		else:
			notice = "Lost the room."
	join_denied.emit()


func _accept(id: int) -> void:
	if accepted.has(id):
		return
	accepted[id] = true
	welcome.rpc_id(id, room_name)
	share_times.rpc_id(id, Board.blob())
	peer_ready.emit(id)


@rpc("any_peer", "reliable")
func submit_password(secret: String) -> void:
	if multiplayer.get_unique_id() != 1:
		return
	var id := multiplayer.get_remote_sender_id()
	if id <= 0:
		return
	if secret == room_password:
		_accept(id)
		return
	deny.rpc_id(id)
	if peer != null:
		peer.disconnect_peer(id, true)


@rpc("authority", "reliable")
func describe(named: String, locked: bool) -> void:
	if not _awaiting:
		return
	room_name = named
	if locked and password_try == "":
		need_password.emit(named)
		return
	submit_password.rpc_id(1, password_try)


@rpc("authority", "reliable")
func welcome(named: String) -> void:
	room_name = named
	_awaiting = false
	join_accepted.emit()
	share_times.rpc_id(1, Board.blob())


@rpc("any_peer", "reliable")
func share_times(text: String) -> void:
	Board.take_blob(text)
	if multiplayer.get_unique_id() != 1:
		return
	var sender := multiplayer.get_remote_sender_id()
	if sender <= 0:
		return
	for peer_id in accepted.keys():
		if int(peer_id) == sender:
			continue
		share_times.rpc_id(int(peer_id), text)


@rpc("authority", "reliable")
func deny() -> void:
	notice = "Wrong password."
	_awaiting = false
	join_denied.emit()
	offline()


func _open_beacon() -> void:
	_close_beacon()
	_beacon = PacketPeerUDP.new()
	_beacon.set_broadcast_enabled(true)
	if _beacon.bind(0) != OK:
		_beacon = null
		return


func _close_beacon() -> void:
	_beacon_wait = 0.0
	if _beacon != null:
		_beacon.close()
		_beacon = null


func _shout() -> void:
	if _beacon == null:
		return
	var locked := "1" if room_password != "" else "0"
	var packet := ("RL1\t%s\t%s" % [room_name, locked]).to_utf8_buffer()
	for dest in _broadcast_targets():
		_beacon.set_dest_address(dest, DISCOVERY)
		_beacon.put_packet(packet)
	for dest in _tailscale_peers:
		if dest == _tailscale_ip:
			continue
		_beacon.set_dest_address(dest, DISCOVERY)
		_beacon.put_packet(packet)


func _broadcast_targets() -> PackedStringArray:
	var out := PackedStringArray()
	out.append("255.255.255.255")
	out.append("127.0.0.1")
	for address in IP.get_local_addresses():
		var text := str(address)
		if _is_tailscale_ip(text) or _rank_ip(text) >= 99:
			continue
		var parts := text.split(".")
		if parts.size() != 4:
			continue
		var dest := "%s.%s.%s.255" % [parts[0], parts[1], parts[2]]
		if not out.has(dest):
			out.append(dest)
	return out


func _hear() -> void:
	if _listen == null:
		return
	while _listen.get_available_packet_count() > 0:
		var ip := _listen.get_packet_ip()
		var text := _listen.get_packet().get_string_from_utf8()
		var parts := text.split("\t", false)
		if parts.size() < 3 or parts[0] != "RL1":
			continue
		if not _usable_ip(ip):
			continue
		var named := parts[1].strip_edges()
		if named.is_empty():
			continue
		rooms[ip] = {"name": named, "locked": parts[2] == "1", "seen": 0.0}


func _expire(delta: float) -> void:
	var dead: Array[String] = []
	for ip in rooms.keys():
		rooms[ip]["seen"] = float(rooms[ip]["seen"]) + delta
		if float(rooms[ip]["seen"]) > 3.0:
			dead.append(str(ip))
	for ip in dead:
		rooms.erase(ip)


func _usable_ip(ip: String) -> bool:
	if ip.is_empty() or ip.contains(":"):
		return false
	var parts := ip.split(".")
	if parts.size() != 4:
		return false
	for part in parts:
		if not part.is_valid_int():
			return false
		var n := int(part)
		if n < 0 or n > 255:
			return false
	return ip != "0.0.0.0" and ip != "255.255.255.255"


func _refresh_tailscale() -> void:
	var bin := _tailscale_bin()
	if bin == "":
		_tailscale_ip = _local_tailscale_address()
		_tailscale_peers = PackedStringArray()
		return
	var output: Array = []
	var code := OS.execute(bin, PackedStringArray(["status", "--json"]), output, true, false)
	if code != 0:
		_tailscale_ip = _local_tailscale_address()
		_tailscale_peers = PackedStringArray()
		return
	var text := ""
	for line in output:
		text += str(line) + "\n"
	apply_tailscale_status(text)
	if _tailscale_ip == "":
		_tailscale_ip = _local_tailscale_address()


func apply_tailscale_status(text: String) -> void:
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		return
	var backend := str(data.get("BackendState", ""))
	if backend != "" and backend != "Running":
		_tailscale_ip = ""
		_tailscale_peers = PackedStringArray()
		return
	var self_node = data.get("Self", {})
	var ip := ""
	if typeof(self_node) == TYPE_DICTIONARY:
		ip = _first_tailscale_ip(self_node.get("TailscaleIPs", []))
	var peers := PackedStringArray()
	var peer_map = data.get("Peer", {})
	if typeof(peer_map) == TYPE_DICTIONARY:
		for key in peer_map.keys():
			var person = peer_map[key]
			if typeof(person) != TYPE_DICTIONARY:
				continue
			if not bool(person.get("Online", false)):
				continue
			var peer_ip := _first_tailscale_ip(person.get("TailscaleIPs", []))
			if peer_ip != "" and not peers.has(peer_ip):
				peers.append(peer_ip)
	_tailscale_ip = ip
	_tailscale_peers = peers


func _tailscale_bin() -> String:
	var candidates := PackedStringArray()
	candidates.append("C:/Program Files/Tailscale/tailscale.exe")
	var local := OS.get_environment("LOCALAPPDATA")
	if local != "":
		candidates.append(local.replace("\\", "/") + "/Tailscale/tailscale.exe")
	for path in candidates:
		if FileAccess.file_exists(path):
			return path
	if _tailscale_path_checked:
		return ""
	_tailscale_path_checked = true
	var output: Array = []
	var code := OS.execute("where", PackedStringArray(["tailscale"]), output, true, false)
	if code == 0:
		for line in output:
			var found := str(line).strip_edges()
			if found != "" and FileAccess.file_exists(found):
				return found
	return ""


func _local_tailscale_address() -> String:
	for address in IP.get_local_addresses():
		var text := str(address)
		if _is_tailscale_ip(text):
			return text
	return ""


func _first_tailscale_ip(values) -> String:
	if typeof(values) != TYPE_ARRAY:
		return ""
	for value in values:
		var text := str(value)
		if _is_tailscale_ip(text):
			return text
	return ""


func _is_tailscale_ip(address: String) -> bool:
	if not address.begins_with("100."):
		return false
	var parts := address.split(".")
	if parts.size() != 4:
		return false
	var second := int(parts[1])
	return second >= 64 and second <= 127


func _clean_room(raw: String) -> String:
	var named := raw.strip_edges().replace("\t", " ").replace("\n", " ").replace("\r", " ")
	if named.length() > 24:
		named = named.substr(0, 24).strip_edges()
	if named.is_empty():
		return "Roofline room"
	return named


func _rank_ip(address: String) -> int:
	if address.contains(":"):
		return 99
	if address.begins_with("127."):
		return 99
	if address.begins_with("192.168."):
		return 0
	if address.begins_with("10."):
		return 1
	var parts := address.split(".")
	if parts.size() == 4 and address.begins_with("172."):
		var second := int(parts[1])
		if second >= 16 and second <= 31:
			return 2
	if parts.size() == 4:
		return 3
	return 99
