extends RefCounted

# Friends' speedrun times live in user://times.cfg, not the profile.
# Your own times stay in the ghost files.

const GhostStore := preload("res://scripts/ghosts.gd")
const Catalog := preload("res://scripts/catalog.gd")
const _PATH := "user://times.cfg"


static func digest() -> String:
	var lines: PackedStringArray = PackedStringArray()
	_append_self(lines, "practice", Catalog.all())
	_append_self(lines, "challenge", Catalog.challenges())
	return "\n".join(lines)


static func blob() -> String:
	var lines: PackedStringArray = PackedStringArray()
	var who := Profile.screen_name()
	for map in Catalog.all():
		var time := GhostStore.best_time(str(map["id"]))
		if time > 0.0:
			lines.append("%s\tpractice\t%s\t%.3f" % [who, str(map["id"]), time])
	for map in Catalog.challenges():
		var time := GhostStore.best_time(str(map["id"]))
		if time > 0.0:
			lines.append("%s\tchallenge\t%s\t%.3f" % [who, str(map["id"]), time])
	for row in _load():
		lines.append("%s\t%s\t%s\t%.3f" % [str(row["who"]), str(row["mode"]), str(row["map"]), float(row["time"])])
	return "\n".join(lines)


static func take_digest(who: String, text: String) -> void:
	var named := Profile.sanitize_name(who)
	for line in text.split("\n"):
		var bits := line.split("|")
		if bits.size() != 3:
			continue
		remember(named, str(bits[0]), str(bits[1]), float(bits[2]))


static func take_blob(text: String) -> void:
	for line in text.split("\n"):
		var bits := line.split("\t")
		if bits.size() != 4:
			continue
		remember(str(bits[0]), str(bits[1]), str(bits[2]), float(bits[3]))


static func remember(who: String, mode: String, map_id: String, time: float) -> void:
	if time <= 0.0 or not _known(mode, map_id):
		return
	var named := Profile.sanitize_name(who)
	if named == Profile.screen_name():
		return
	var rows := _load()
	var found := false
	for i in rows.size():
		var row: Dictionary = rows[i]
		if str(row["who"]) == named and str(row["mode"]) == mode and str(row["map"]) == map_id:
			found = true
			if time < float(row["time"]):
				row["time"] = time
				rows[i] = row
			break
	if not found:
		rows.append({"who": named, "mode": mode, "map": map_id, "time": time})
	_save(rows)


static func rows(scope: String, mode: String) -> Array:
	var maps: Array = Catalog.all() if mode == "practice" else Catalog.challenges()
	var friends := _load()
	var out: Array = []
	for map in maps:
		var id := str(map["id"])
		var people: Array = []
		if scope == "self" or scope == "global":
			var mine := GhostStore.best_time(id)
			if mine > 0.0:
				people.append({"name": Profile.screen_name(), "time": mine, "you": true})
		if scope == "friends" or scope == "global":
			for row in friends:
				if str(row["mode"]) != mode or str(row["map"]) != id:
					continue
				people.append({"name": str(row["who"]), "time": float(row["time"]), "you": false})
		people.sort_custom(_sooner)
		out.append({"name": str(map["name"]), "id": id, "times": people})
	return out


static func _sooner(a: Dictionary, b: Dictionary) -> bool:
	return float(a["time"]) < float(b["time"])


static func _append_self(lines: PackedStringArray, mode: String, maps: Array) -> void:
	for map in maps:
		var time := GhostStore.best_time(str(map["id"]))
		if time > 0.0:
			lines.append("%s|%s|%.3f" % [mode, str(map["id"]), time])


static func _known(mode: String, map_id: String) -> bool:
	if mode != "practice" and mode != "challenge":
		return false
	var maps: Array = Catalog.all() if mode == "practice" else Catalog.challenges()
	for map in maps:
		if str(map["id"]) == map_id:
			return true
	return false


static func _load() -> Array:
	var rows: Array = []
	if not FileAccess.file_exists(_PATH):
		return rows
	var file := FileAccess.open(_PATH, FileAccess.READ)
	if file == null:
		return rows
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line == "":
			continue
		var bits := line.split("\t")
		if bits.size() != 4:
			continue
		var time := float(bits[3])
		if time <= 0.0:
			continue
		rows.append({
			"who": str(bits[0]),
			"mode": str(bits[1]),
			"map": str(bits[2]),
			"time": time,
		})
	return rows


static func _save(rows: Array) -> void:
	var file := FileAccess.open(_PATH, FileAccess.WRITE)
	if file == null:
		return
	for row in rows:
		file.store_line("%s\t%s\t%s\t%.3f" % [str(row["who"]), str(row["mode"]), str(row["map"]), float(row["time"])])
