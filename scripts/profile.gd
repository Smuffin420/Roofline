extends Node

const Hats := preload("res://scripts/hats.gd")
const Styles := preload("res://scripts/styles.gd")
const Trails := preload("res://scripts/trails.gd")

# A finish always pays. Place, a clean run, and the clock add on top.
# With ten runners, top half is 4th and 5th. 1st through 3rd take their own bonus instead.
const FINISH_XP := 40
const WIN_XP := 110
const SECOND_XP := 55
const THIRD_XP := 35
const TOP_HALF_XP := 25
const FLAWLESS_XP := 35
const PACE_XP := 20
const CHALLENGE_XP := 100
const CHALLENGE_AGAIN_XP := 25
const CHALLENGE_CLEAN_XP := 15
const CHALLENGE_PACE_XP := 10

var xp := 0
var crowns := 0
var wins := 0
var races := 0
var last_xp := 0
var last_crown := 0
var last_place := 0
var last_finished := false
var last_bonuses: Array = []
var runner_name := "Runner"
var hue := 0.0
var hat := "cap"
var style := "bulbous"
var trail := "off"
var third_person := false
var cleared := PackedStringArray()
var dev_unlock := false


func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://profile.cfg") != OK:
		return
	xp = int(cfg.get_value("save", "xp", 0))
	crowns = int(cfg.get_value("save", "crowns", 0))
	wins = int(cfg.get_value("save", "wins", 0))
	races = int(cfg.get_value("save", "races", 0))
	runner_name = sanitize_name(str(cfg.get_value("save", "name", "Runner")))
	hue = clampf(float(cfg.get_value("save", "hue", 0.0)), 0.0, 1.0)
	dev_unlock = bool(cfg.get_value("save", "dev_unlock", false))
	hat = str(cfg.get_value("save", "hat", "cap"))
	if not Hats.is_open(hat, reward_level()):
		hat = "cap"
	style = str(cfg.get_value("save", "style", "bulbous"))
	if not Styles.is_open(style, reward_level()):
		style = "bulbous"
	trail = str(cfg.get_value("save", "trail", "off"))
	if not Trails.is_open(trail, reward_level()):
		trail = "off"
	third_person = bool(cfg.get_value("save", "third", false))
	var raw := str(cfg.get_value("save", "cleared", ""))
	cleared = PackedStringArray()
	if raw != "":
		for piece in raw.split(","):
			if piece != "":
				cleared.append(piece)


func trophy_label() -> String:
	if crowns == 1:
		return "1 trophy"
	return "%d trophies" % crowns


func screen_name() -> String:
	return runner_name


func set_screen_name(raw: String) -> void:
	runner_name = sanitize_name(raw)
	_save()


func sanitize_name(raw: String) -> String:
	var cleaned := raw.strip_edges()
	if cleaned.length() > 16:
		cleaned = cleaned.substr(0, 16)
	if cleaned.is_empty():
		return "Runner"
	return cleaned


func set_hue(value: float) -> void:
	hue = clampf(value, 0.0, 1.0)
	_save()


func color_from_hue(value: float) -> Color:
	return Color.from_hsv(clampf(value, 0.0, 1.0), 0.7, 0.96)


func player_color() -> Color:
	return color_from_hue(hue)


func hat_id() -> String:
	if Hats.is_open(hat, reward_level()):
		return hat
	return "cap"


func set_hat(id: String) -> void:
	if not Hats.is_open(id, reward_level()):
		return
	hat = id
	_save()


func style_id() -> String:
	if Styles.is_open(style, reward_level()):
		return style
	return "bulbous"


func set_style(id: String) -> void:
	if not Styles.is_open(id, reward_level()):
		return
	style = id
	_save()


func trail_id() -> String:
	if Trails.is_open(trail, reward_level()):
		return trail
	return "off"


func set_trail(id: String) -> void:
	if not Trails.is_open(id, reward_level()):
		return
	trail = id
	_save()


func use_third() -> bool:
	return third_person


func set_third_person(on: bool) -> void:
	third_person = on
	_save()


func cleared_challenge(id: String) -> bool:
	return cleared.has(id)


func cleared_count() -> int:
	return cleared.size()


func grant_challenge(id: String, falls: int, race_seconds: float, par_seconds: float) -> void:
	last_place = 1
	last_finished = true
	last_crown = 0
	if not cleared.has(id):
		cleared.append(id)
		last_xp = CHALLENGE_XP
		last_bonuses = [{"name": "First clear", "xp": CHALLENGE_XP}]
		xp += last_xp
		_save()
		return
	last_bonuses = [{"name": "Clear", "xp": CHALLENGE_AGAIN_XP}]
	if falls <= 0:
		last_bonuses.append({"name": "Flawless", "xp": CHALLENGE_CLEAN_XP})
	if par_seconds > 0.0 and race_seconds > 0.0 and race_seconds <= par_seconds:
		last_bonuses.append({"name": "On pace", "xp": CHALLENGE_PACE_XP})
	last_xp = 0
	for line in last_bonuses:
		last_xp += int(line["xp"])
	xp += last_xp
	_save()


func bonuses_for(place: int, did_finish: bool, falls: int, race_seconds: float, par_seconds: float, field: int, scale: float = 1.0) -> Array:
	var lines: Array = []
	if not did_finish:
		return lines
	lines.append({"name": "Finish", "xp": _scaled(FINISH_XP, scale)})
	if place == 1:
		lines.append({"name": "Win", "xp": _scaled(WIN_XP, scale)})
	elif place == 2:
		lines.append({"name": "2nd", "xp": _scaled(SECOND_XP, scale)})
	elif place == 3:
		lines.append({"name": "3rd", "xp": _scaled(THIRD_XP, scale)})
	elif place > 3 and place <= _top_half(field):
		lines.append({"name": "Top half", "xp": _scaled(TOP_HALF_XP, scale)})
	if falls <= 0:
		lines.append({"name": "Flawless", "xp": _scaled(FLAWLESS_XP, scale)})
	if par_seconds > 0.0 and race_seconds > 0.0 and race_seconds <= par_seconds:
		lines.append({"name": "On pace", "xp": _scaled(PACE_XP, scale)})
	return lines


func _scaled(amount: int, scale: float) -> int:
	if scale >= 0.99:
		return amount
	return maxi(1, int(round(float(amount) * scale)))


func _top_half(field: int) -> int:
	return int(ceil(float(maxi(field, 1)) / 2.0))


func series_bonuses(place: int, did_finish: bool, falls: int, race_seconds: float, par_seconds: float, round_index: int) -> Array:
	var lines: Array = []
	if not did_finish:
		return lines
	var round_i := clampi(round_index, 0, 2)
	var finish_pay := 18
	var clean_pay := 8
	var pace_pay := 6
	var round_label := "Round 1"
	if round_i == 1:
		finish_pay = 36
		clean_pay = 16
		pace_pay = 12
		round_label = "Round 2"
	elif round_i >= 2:
		finish_pay = 60
		clean_pay = 40
		pace_pay = 24
		round_label = "Final"
	lines.append({"name": round_label, "xp": finish_pay})
	var place_pay := 0
	var place_label := ""
	if round_i == 0:
		if place == 1:
			place_pay = 36
			place_label = "1st"
		elif place == 2:
			place_pay = 24
			place_label = "2nd"
		elif place == 3:
			place_pay = 16
			place_label = "3rd"
		elif place <= 10:
			place_pay = 12
			place_label = "Through"
	elif round_i == 1:
		if place == 1:
			place_pay = 70
			place_label = "1st"
		elif place == 2:
			place_pay = 42
			place_label = "2nd"
		elif place == 3:
			place_pay = 28
			place_label = "3rd"
		elif place <= 5:
			place_pay = 20
			place_label = "Through"
	elif place == 1:
		place_pay = 220
		place_label = "Last standing"
	elif place == 2:
		place_pay = 100
		place_label = "2nd"
	elif place == 3:
		place_pay = 70
		place_label = "3rd"
	elif place == 4:
		place_pay = 45
		place_label = "4th"
	elif place == 5:
		place_pay = 30
		place_label = "5th"
	if place_pay > 0:
		lines.append({"name": place_label, "xp": place_pay})
	if falls <= 0:
		lines.append({"name": "Flawless", "xp": clean_pay})
	if par_seconds > 0.0 and race_seconds > 0.0 and race_seconds <= par_seconds:
		lines.append({"name": "On pace", "xp": pace_pay})
	return lines


func crown_for(trophy: bool, did_finish: bool, place: int, round_index: int) -> int:
	if not trophy or not did_finish or place != 1:
		return 0
	if round_index >= 0 and round_index < 2:
		return 0
	return 1


func grant(place: int, did_finish: bool, falls: int, race_seconds: float, par_seconds: float, field: int, scale: float = 1.0, trophy: bool = true, round_index: int = -1) -> void:
	last_place = place
	last_finished = did_finish
	if round_index >= 0:
		last_bonuses = series_bonuses(place, did_finish, falls, race_seconds, par_seconds, round_index)
	else:
		last_bonuses = bonuses_for(place, did_finish, falls, race_seconds, par_seconds, field, scale)
	last_xp = 0
	for line in last_bonuses:
		last_xp += int(line["xp"])
	last_crown = crown_for(trophy, did_finish, place, round_index)
	xp += last_xp
	crowns += last_crown
	races += 1
	if last_crown > 0:
		wins += 1
	_save()


func level() -> int:
	var lv := 1
	while xp >= xp_to_reach(lv + 1) and lv < 40:
		lv += 1
	return lv


func reward_level() -> int:
	if dev_unlock:
		return 40
	return level()


func set_dev_unlock(on: bool) -> void:
	dev_unlock = on
	if not dev_unlock:
		if not Hats.is_open(hat, level()):
			hat = "cap"
		if not Styles.is_open(style, level()):
			style = "bulbous"
		if not Trails.is_open(trail, level()):
			trail = "off"
	_save()


func xp_to_reach(lv: int) -> int:
	if lv <= 1:
		return 0
	return 60 * (lv - 1) * lv


func level_progress() -> float:
	var lv := level()
	var start := xp_to_reach(lv)
	var goal := xp_to_reach(lv + 1)
	if goal <= start:
		return 1.0
	return clampf(float(xp - start) / float(goal - start), 0.0, 1.0)


func xp_into_level() -> int:
	return xp - xp_to_reach(level())


func xp_this_level() -> int:
	return xp_to_reach(level() + 1) - xp_to_reach(level())


func next_unlock(lv := -1) -> Dictionary:
	if lv < 0:
		lv = reward_level()
	var best: Dictionary = {}
	var pool: Array = []
	pool.append_array(Styles.all())
	pool.append_array(Trails.all())
	pool.append_array(load("res://scripts/emotes.gd").all())
	for item in pool:
		if int(item["level"]) <= lv:
			continue
		if best.is_empty() or int(item["level"]) < int(best["level"]):
			best = item
	return best


func unlocked_names() -> Array:
	var lv := reward_level()
	var names: Array = []
	for item in Styles.all():
		if int(item["level"]) <= lv:
			names.append(str(item["name"]))
	return names


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("save", "xp", xp)
	cfg.set_value("save", "crowns", crowns)
	cfg.set_value("save", "wins", wins)
	cfg.set_value("save", "races", races)
	cfg.set_value("save", "name", runner_name)
	cfg.set_value("save", "hue", hue)
	cfg.set_value("save", "hat", hat)
	cfg.set_value("save", "style", style)
	cfg.set_value("save", "trail", trail)
	cfg.set_value("save", "third", third_person)
	cfg.set_value("save", "cleared", ",".join(cleared))
	cfg.set_value("save", "dev_unlock", dev_unlock)
	cfg.save("user://profile.cfg")
