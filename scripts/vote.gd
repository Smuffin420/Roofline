extends Control

const Catalog := preload("res://scripts/catalog.gd")
const ThemeLib := preload("res://scripts/theme.gd")
const Shots := preload("res://scripts/shots.gd")
const Board := preload("res://scripts/board.gd")

var roster := {}
var cards := {}
var count_labels := {}
var clock: Label
var address_label: Label
var lobby_box: HFlowContainer
var bots_button: Button
var bots_note: Label
var fill_bots := true
var time_left := 20.0
var counting := false
var sealed := false
var closing := false
var my_pick := ""
var sync_wait := 0.0
var ballot: Array = []
var grid: GridContainer


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not Match.battle and not Match.practice and not Match.challenge and not Match.audit and not Match.series:
		Match.open_series()
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = ThemeLib.make()
	var bg := ColorRect.new()
	bg.color = Color("efe8dc")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 36
	root.offset_top = 28
	root.offset_right = -36
	root.offset_bottom = -24
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 16)
	var back := ThemeLib.button("Back", _to_menu)
	back.custom_minimum_size = Vector2(120, 40)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	head.add_child(back)
	var kicker := ThemeLib.label("VOTE THE NEXT ROOF", 18, Color("e23b2f"))
	kicker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kicker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(kicker)
	root.add_child(head)
	var heading := "Three maps. Majority wins."
	if Match.series:
		heading = Match.round_heading()
	var title := ThemeLib.label(heading, 40, Color("1c1915"))
	title.add_theme_font_size_override("font_size", 40)
	root.add_child(title)

	var career := "Level %d    ·    %d XP    ·    %s" % [Profile.level(), Profile.xp, Profile.trophy_label()]
	root.add_child(ThemeLib.label(career, 18, Color("3c3832")))
	root.add_child(ThemeLib.bar(Profile.level_progress(), 420))
	var nxt := Profile.next_unlock()
	if nxt.is_empty():
		root.add_child(ThemeLib.label("Every reward is unlocked.", 16, Color("5c564e")))
	else:
		root.add_child(ThemeLib.label("Next, level %s: %s." % [str(nxt["level"]), str(nxt["name"])], 16, Color("5c564e")))

	clock = ThemeLib.label(_status_line(), 20, Color("1c1915"))
	root.add_child(clock)
	address_label = ThemeLib.label("", 16, Color("3c3832"))
	address_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(address_label)
	lobby_box = HFlowContainer.new()
	lobby_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lobby_box.alignment = FlowContainer.ALIGNMENT_CENTER
	lobby_box.add_theme_constant_override("h_separation", 22)
	lobby_box.add_theme_constant_override("v_separation", 6)
	root.add_child(lobby_box)
	fill_bots = Match.lobby_bots
	if Network.is_online():
		call_deferred("_share_board")
	bots_button = Button.new()
	bots_button.custom_minimum_size = Vector2(0, 40)
	bots_button.visible = false
	bots_button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	bots_button.pressed.connect(_toggle_bots)
	root.add_child(bots_button)
	bots_note = ThemeLib.label("", 16, Color("5c564e"))
	bots_note.visible = false
	root.add_child(bots_note)
	_paint_bots()

	grid = GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	root.add_child(grid)

	if not Network.is_online() or multiplayer.is_server():
		ballot = _roll_ballot()
		_build_cards()

	if Network.is_online():
		_open_room()
	else:
		address_label.visible = false
		lobby_box.visible = false
		bots_button.visible = false
		bots_note.visible = false

	if OS.get_environment("ROOFLINE_BOT") == "1" or OS.get_environment("ROOFLINE_FIELD") == "1":
		var forced := OS.get_environment("ROOFLINE_MAP")
		_begin(forced if forced != "" else "annex")


func _roll_ballot() -> Array:
	var pool: Array = []
	for id in Catalog.ids():
		if Match.fresh(str(id)):
			pool.append(str(id))
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = pool[i]
		pool[i] = pool[j]
		pool[j] = tmp
	var offered: Array = []
	for i in mini(3, pool.size()):
		offered.append(str(pool[i]))
	return offered


func _vote_window() -> float:
	if Match.series:
		return 8.0
	return 20.0


func _same_ballot(next: Array) -> bool:
	if next.size() != ballot.size() or cards.size() != next.size():
		return false
	for i in next.size():
		if str(next[i]) != str(ballot[i]):
			return false
	return true


func _build_cards() -> void:
	if grid == null:
		return
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	cards.clear()
	count_labels.clear()
	var picked: Array[Button] = []
	for raw in ballot:
		var id := str(raw)
		var map := Catalog.get_map(id)
		var box := VBoxContainer.new()
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box.add_theme_constant_override("separation", 6)
		var button := Shots.card(str(map["name"]))
		button.pressed.connect(_pick.bind(id))
		box.add_child(button)
		var votes_label := ThemeLib.label("0 votes", 16, Color("5c564e"))
		box.add_child(votes_label)
		grid.add_child(box)
		cards[id] = button
		count_labels[id] = votes_label
		picked.append(button)
	_wire_grid(picked)
	Shots.request(self, ballot.duplicate(), _on_shot)
	if not picked.is_empty() and not sealed:
		picked[0].call_deferred("grab_focus")


func _on_shot(id: String, tex: Texture2D) -> void:
	if cards.has(id):
		Shots.fill(cards[id], tex)


func _open_room() -> void:
	if multiplayer.is_server():
		if not Network.peer_ready.is_connected(_peer_in):
			Network.peer_ready.connect(_peer_in)
		multiplayer.peer_disconnected.connect(_peer_out)
		var kept := ""
		_remember(multiplayer.get_unique_id(), Profile.screen_name(), Profile.hue, kept)
		for id in Network.accepted.keys():
			_peer_in(int(id))
		_show_room()
		_push_state()
		return
	address_label.visible = Network.room_name != ""
	address_label.text = Network.room_name
	multiplayer.connected_to_server.connect(_hello)
	multiplayer.connection_failed.connect(_failed)
	multiplayer.server_disconnected.connect(_host_gone)
	var status := multiplayer.multiplayer_peer.get_connection_status()
	if status == MultiplayerPeer.CONNECTION_CONNECTED:
		_hello()
	elif status == MultiplayerPeer.CONNECTION_CONNECTING:
		clock.text = _status_line()
	else:
		_failed()


func _unhandled_input(event: InputEvent) -> void:
	if sealed or not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	_to_menu()


func _wire_grid(picked: Array[Button]) -> void:
	var cols := 3
	var count := picked.size()
	if count == 0:
		return
	var rows := int(ceil(float(count) / float(cols)))
	for i in count:
		var button := picked[i]
		var col := i % cols
		var row := int(i / cols)
		var row_start := row * cols
		var row_len := mini(cols, count - row_start)
		var left_i := row_start + ((col - 1 + row_len) % row_len)
		var right_i := row_start + ((col + 1) % row_len)
		var up_i := i - cols
		if up_i < 0:
			up_i = i + (rows - 1) * cols
			if up_i >= count:
				up_i = count - 1
		var down_i := i + cols
		if down_i >= count:
			down_i = col
		button.focus_neighbor_left = button.get_path_to(picked[left_i])
		button.focus_neighbor_right = button.get_path_to(picked[right_i])
		button.focus_neighbor_top = button.get_path_to(picked[up_i])
		button.focus_neighbor_bottom = button.get_path_to(picked[down_i])


func _process(delta: float) -> void:
	if sealed or not Network.is_online():
		return
	if multiplayer.is_server():
		if _all_voted():
			_close()
			return
		var seated := _seated_count()
		if seated < 2:
			if counting:
				counting = false
				time_left = _vote_window()
				_push_state()
		else:
			if not counting:
				counting = true
				time_left = _vote_window()
				sync_wait = 0.0
				_push_state()
			time_left = maxf(0.0, time_left - delta)
			sync_wait += delta
			if sync_wait >= 0.5:
				sync_wait = 0.0
				_push_state()
			if time_left <= 0.0:
				_close()
				return
		clock.text = _status_line()
		if address_label:
			address_label.text = "%s    ·    %s" % [Network.room_name, Network.host_reach_line()]
		return
	if counting:
		time_left = maxf(0.0, time_left - delta)
	clock.text = _status_line()


func _status_line() -> String:
	if not Network.is_online():
		if Match.series:
			return "Pick a roof that has not been run this session."
		return "You are the only vote. Pick a roof and the race starts."
	if not multiplayer.is_server() and not Network.connected():
		var target := Network.join_address if Network.join_address != "" else "the host"
		return "Connecting to %s..." % target
	if _seated_count() < 2:
		return "Waiting for another player. The race cannot start until someone joins."
	if Match.series:
		return "%s. Voting closes in %d." % [Match.short_round(), int(ceil(time_left))]
	return "Voting closes in %d. The race loads when everyone has voted." % int(ceil(time_left))


func _pick(id: String) -> void:
	if sealed:
		return
	my_pick = id
	_paint_counts()
	if not Network.is_online():
		_begin(id)
		return
	if multiplayer.is_server():
		_note(multiplayer.get_unique_id(), id)
		return
	if Network.connected():
		submit_vote.rpc_id(1, id)


func _seated_count() -> int:
	var n := 0
	for person in roster.values():
		if str(person["name"]) == "Joining":
			continue
		n += 1
	return n


func _remember(peer_id: int, dname: String, hue: float, vote: String) -> void:
	roster[peer_id] = {
		"name": dname,
		"hue": clampf(hue, 0.0, 1.0),
		"vote": vote,
	}


func _note(peer_id: int, id: String) -> void:
	if sealed or not cards.has(id):
		return
	if not roster.has(peer_id):
		_remember(peer_id, "Joining", 0.0, id)
	else:
		roster[peer_id]["vote"] = id
	_show_room()
	_push_state()
	_try_finish()


func _try_finish() -> void:
	if _all_voted():
		_close()


func _all_voted() -> bool:
	if _seated_count() < 2:
		return false
	for person in roster.values():
		if str(person["name"]) == "Joining":
			continue
		if str(person["vote"]) == "":
			return false
	return true


func _close() -> void:
	if sealed or closing or not multiplayer.is_server():
		return
	if _seated_count() < 2:
		return
	var best := -1
	var tied: Array = []
	for key in cards.keys():
		var n := 0
		for person in roster.values():
			if str(person["vote"]) == str(key):
				n += 1
		if n > best:
			best = n
			tied = [str(key)]
		elif n == best:
			tied.append(str(key))
	if tied.is_empty() or best <= 0:
		tied = ballot.duplicate()
		if tied.is_empty():
			tied = Catalog.ids()
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var winner := str(tied[rng.randi_range(0, tied.size() - 1)])
	closing = true
	start_map.rpc(winner)


func _begin(id: String) -> void:
	if sealed:
		return
	if Network.is_online() and multiplayer.is_server() and _seated_count() < 2:
		closing = false
		return
	sealed = true
	Match.begin_race(id)
	if Match.series:
		Match.note_played(id)
		Match.fill_bots = Match.round_index == 0 and (not Network.is_online() or fill_bots)
	elif Network.is_online():
		Match.fill_bots = fill_bots
	if clock:
		clock.text = "Loading the race..."
	_load_race.call_deferred()


func _load_race() -> void:
	Curtain.go("res://scenes/race.tscn", "Loading the roof.")


func _host_gone() -> void:
	Network.notice = "The host left the room."
	_to_menu()


func _to_menu() -> void:
	if multiplayer.server_disconnected.is_connected(_host_gone):
		multiplayer.server_disconnected.disconnect(_host_gone)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Network.offline()
	Curtain.go("res://scenes/menu.tscn", "Loading.")


func _failed() -> void:
	var target := Network.join_address if Network.join_address != "" else "the host"
	Network.notice = "Couldn't reach %s. Same Wi-Fi uses the host's IPv4. Other houses need the public IP and UDP port 7777 open." % target
	_to_menu()


func _hello() -> void:
	announce.rpc_id(1, Profile.screen_name(), Profile.hue)
	if my_pick != "":
		submit_vote.rpc_id(1, my_pick)


func _peer_in(id: int) -> void:
	if roster.has(id):
		return
	_remember(id, "Joining", 0.0, "")
	_show_room()
	_push_state()


func _peer_out(id: int) -> void:
	roster.erase(id)
	if _seated_count() < 2:
		counting = false
		time_left = _vote_window()
	_show_room()
	_push_state()


func _show_room() -> void:
	if lobby_box == null:
		return
	for child in lobby_box.get_children():
		lobby_box.remove_child(child)
		child.queue_free()
	var people: Array = roster.keys()
	people.sort()
	if people.is_empty() and Network.is_online():
		lobby_box.add_child(_chip(Profile.screen_name(), Profile.hue, my_pick))
	for peer_id in people:
		var person: Dictionary = roster[peer_id]
		lobby_box.add_child(_chip(str(person["name"]), float(person["hue"]), str(person["vote"])))
	if multiplayer.is_server():
		address_label.visible = true
		address_label.text = "%s    ·    %s" % [Network.room_name, Network.host_reach_line()]
	else:
		address_label.visible = Network.room_name != ""
		address_label.text = Network.room_name
	_paint_counts()
	_paint_bots()
	clock.text = _status_line()


func _chip(dname: String, hue: float, vote: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	var swatch := ColorRect.new()
	swatch.custom_minimum_size = Vector2(16, 16)
	swatch.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	swatch.color = Profile.color_from_hue(hue)
	row.add_child(swatch)
	var line := dname
	if vote == "":
		line += "    choosing"
	else:
		line += "    " + str(Catalog.get_map(vote)["name"])
	var label := ThemeLib.label(line, 18, Color("1c1915"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	row.add_child(label)
	return row


func _paint_counts() -> void:
	for key in cards.keys():
		var n := 0
		for person in roster.values():
			if str(person["vote"]) == str(key):
				n += 1
		if count_labels.has(key):
			count_labels[key].text = "1 vote" if n == 1 else "%d votes" % n
		if cards.has(key):
			Shots.mark(cards[key], str(key) == my_pick)


func _push_state() -> void:
	if sealed or not multiplayer.is_server():
		return
	var ids: Array = []
	var names: Array = []
	var hues: Array = []
	var picks: Array = []
	var order: Array = roster.keys()
	order.sort()
	for peer_id in order:
		var person: Dictionary = roster[peer_id]
		ids.append(int(peer_id))
		names.append(str(person["name"]))
		hues.append(float(person["hue"]))
		picks.append(str(person["vote"]))
	apply_state.rpc(ids, names, hues, picks, time_left, counting, fill_bots, ballot)


@rpc("any_peer", "reliable")
func announce(dname: String, hue: float) -> void:
	if not multiplayer.is_server():
		return
	var id := multiplayer.get_remote_sender_id()
	var vote := ""
	var already := roster.has(id) and str(roster[id]["name"]) != "Joining"
	if roster.has(id):
		vote = str(roster[id]["vote"])
	_remember(id, Profile.sanitize_name(dname), hue, vote)
	if counting and not already:
		time_left = _vote_window()
	_show_room()
	_push_state()
	_try_finish()


@rpc("any_peer", "reliable")
func submit_vote(id: String) -> void:
	if not multiplayer.is_server():
		return
	_note(multiplayer.get_remote_sender_id(), id)


@rpc("authority", "call_local", "reliable")
func apply_state(ids: Array, names: Array, hues: Array, picks: Array, seconds: float, is_counting: bool, bots: bool, offered: Array) -> void:
	roster.clear()
	for i in ids.size():
		_remember(int(ids[i]), str(names[i]), float(hues[i]), str(picks[i]))
	time_left = seconds
	counting = is_counting
	fill_bots = bots
	var next: Array = []
	for id in offered:
		next.append(str(id))
	if not next.is_empty() and not _same_ballot(next):
		ballot = next
		_build_cards()
	_show_room()


func _toggle_bots() -> void:
	if sealed or not Network.is_online() or not multiplayer.is_server():
		return
	fill_bots = not fill_bots
	Match.lobby_bots = fill_bots
	_paint_bots()
	_push_state()


func _paint_bots() -> void:
	if bots_button == null:
		return
	bots_button.text = "Fill lobby with bots    ·    %s" % ("On" if fill_bots else "Off")
	var ink := Color("e23b2f") if fill_bots else Color("efe8dc")
	bots_button.add_theme_color_override("font_color", ink)
	bots_button.add_theme_color_override("font_hover_color", Color("efe8dc"))
	bots_button.add_theme_color_override("font_focus_color", Color("efe8dc"))
	bots_button.add_theme_color_override("font_pressed_color", Color("efe8dc"))
	var hosting := Network.is_online() and multiplayer.is_server()
	bots_button.visible = hosting
	if bots_note == null:
		return
	bots_note.text = "The host is filling empty spots with bots." if fill_bots else "Empty spots stay empty."
	bots_note.visible = Network.is_online() and not hosting and Network.connected()


func _share_board() -> void:
	if not Network.is_online():
		return
	if multiplayer.is_server():
		_publish_board.rpc(Board.blob())
	else:
		_offer_board.rpc_id(1, Profile.screen_name(), Board.digest())


@rpc("any_peer", "reliable")
func _offer_board(who: String, digest: String) -> void:
	if not multiplayer.is_server():
		return
	Board.take_digest(who, digest)
	_publish_board.rpc(Board.blob())


@rpc("authority", "call_local", "reliable")
func _publish_board(blob: String) -> void:
	Board.take_blob(blob)


@rpc("authority", "call_local", "reliable")
func start_map(id: String) -> void:
	_begin(id)
