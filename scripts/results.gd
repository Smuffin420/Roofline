extends Control

const ThemeLib := preload("res://scripts/theme.gd")
const Catalog := preload("res://scripts/catalog.gd")
const GhostStore := preload("res://scripts/ghosts.gd")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = ThemeLib.make()
	settle_rewards()

	var bg := ColorRect.new()
	bg.color = Color("efe8dc")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_CENTER)
	root.offset_left = -520
	root.offset_top = -330
	root.offset_right = 520
	root.offset_bottom = 330
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var map := Catalog.get_map(Match.map_id)
	var kicker := str(map["name"]).to_upper()
	if Match.series:
		kicker = "%s    ·    %s" % [Match.short_round().to_upper(), kicker]
	root.add_child(ThemeLib.label(kicker, 18, Color("e23b2f")))
	var headline := "Race over"
	var reward := "Did not finish. Crossing the line is what pays."
	if Match.series and not Match.ran:
		headline = "Watching"
		if Match.on_final():
			reward = "The final decides the crown."
		else:
			reward = "Top %d are still in." % Match.cut_line()
	elif Match.series and not Match.on_final():
		if Match.through:
			headline = "You're through"
			reward = "Top %d continue." % Match.cut_line()
		else:
			headline = "Eliminated"
			reward = "Top %d continue." % Match.cut_line()
		if Match.your_finished and Profile.last_xp > 0:
			reward = "+%d XP. %s" % [Profile.last_xp, reward]
	elif Match.series and Match.on_final():
		if Match.your_finished and Match.your_place == 1:
			headline = "Last standing"
			reward = "+%d XP" % Profile.last_xp
		elif Match.your_finished:
			headline = "Finished %s" % _ordinal(Match.your_place)
			reward = "+%d XP" % Profile.last_xp
		else:
			headline = "Did not finish"
			reward = "Crossing the line is what pays."
	elif Match.challenge:
		if Match.your_finished and Profile.last_xp > 0:
			headline = "✓  Challenge clear"
			reward = "+%d XP" % Profile.last_xp
		elif Match.your_finished:
			headline = "✓  Challenge clear"
			reward = "No XP this time."
		else:
			headline = "Not this time"
			reward = "Cross the line to get paid."
		if Match.speedrun and Match.your_finished:
			reward += "    ·    " + _practice_reward()
	elif Match.battle:
		if Match.your_finished and Match.your_place == 1:
			headline = "You won the roof"
		elif Match.your_finished:
			headline = "Finished %s" % _ordinal(Match.your_place)
		if Match.your_finished and Profile.last_xp > 0:
			reward = "+%d XP" % Profile.last_xp
		else:
			reward = "Cross the line to get paid."
	elif Match.practice:
		headline = _practice_headline()
		reward = _practice_reward()
	elif Match.your_finished and Match.your_place == 1:
		headline = "You won the roof"
		reward = "+%d XP" % Profile.last_xp
	elif Match.your_finished:
		headline = "Finished %s" % _ordinal(Match.your_place)
		reward = "+%d XP" % Profile.last_xp
	if not Match.practice and not Match.battle and not Match.challenge and Profile.last_crown > 0:
		reward += "    ·    +1 crown" if Match.series else "    ·    +1 trophy"
	root.add_child(ThemeLib.label(headline, 48, Color("1c1915")))
	root.add_child(ThemeLib.label(reward, 22, Color("3c3832")))
	if Match.challenge:
		root.add_child(ThemeLib.label("Deaths  %d" % Match.your_falls, 22, Color("3c3832")))
	if Match.your_finished and Profile.last_xp > 0 and not (Match.practice and not Match.challenge):
		root.add_child(_bonus_list())

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 36)
	var left := VBoxContainer.new()
	var right := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(left)
	columns.add_child(right)
	root.add_child(columns)
	var row_i := 0
	for row in Match.results:
		var place := int(row["place"])
		var clock := str(row["clock"])
		var finished := bool(row.get("finished", true))
		if clock.contains("DNF") or clock == "Eliminated":
			finished = false
		var tag := "%s    %s" % [_ordinal(place), str(row["name"])]
		if Match.series and not Match.on_final() and finished and place <= Match.cut_line():
			tag += "    through"
		if not finished:
			tag += "    Eliminated" if clock == "Eliminated" else "    DNF"
		if bool(row["you"]):
			tag += "    you"
		var color := Color("1f8a70") if finished else Color("8a8175")
		var line := ThemeLib.label(tag, 18, color)
		line.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		var column: VBoxContainer = left if row_i < int(ceil(float(Match.results.size()) / 2.0)) else right
		column.add_child(line)
		row_i += 1

	root.add_child(ThemeLib.label("Level %d    ·    %d / %d XP    ·    %s" % [Profile.level(), Profile.xp_into_level(), Profile.xp_this_level(), Profile.trophy_label()], 18, Color("3c3832")))
	root.add_child(ThemeLib.bar(Profile.level_progress(), 520))
	var nxt := Profile.next_unlock()
	if nxt.is_empty():
		root.add_child(ThemeLib.label("Every hat is unlocked.", 16, Color("5c564e")))
	else:
		root.add_child(ThemeLib.label("Next hat, level %s: %s." % [str(nxt["level"]), str(nxt["name"])], 16, Color("5c564e")))
	var rates := ThemeLib.label(_rates_text(), 16, Color("5c564e"))
	rates.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rates.custom_minimum_size = Vector2(720, 0)
	root.add_child(rates)

	if Network.is_online() and not multiplayer.is_server():
		multiplayer.server_disconnected.connect(_host_left)
	if Match.challenge:
		var again := ThemeLib.button("Run again", _again)
		root.add_child(again)
		root.add_child(ThemeLib.button("Back", _challenge_list))
		again.call_deferred("grab_focus")
	elif Match.practice:
		var again := ThemeLib.button("Run again", _again)
		root.add_child(again)
		root.add_child(ThemeLib.button("Back", _practice))
		again.call_deferred("grab_focus")
	elif Match.series and Match.on_final():
		var done := ThemeLib.button("Back", _menu)
		root.add_child(done)
		done.call_deferred("grab_focus")
	elif Match.series and (Match.through or _hosting()):
		var next_round := ThemeLib.button("Next roof", _next)
		root.add_child(next_round)
		root.add_child(ThemeLib.button("Back", _menu))
		next_round.call_deferred("grab_focus")
	elif Match.series:
		var done := ThemeLib.button("Back", _menu)
		root.add_child(done)
		done.call_deferred("grab_focus")
	else:
		var next_map := ThemeLib.button("Next map", _next)
		root.add_child(next_map)
		root.add_child(ThemeLib.button("Back", _menu))
		next_map.call_deferred("grab_focus")


static func settle_rewards() -> void:
	if Match.challenge:
		if not Match.granted and Match.your_finished:
			var info := Catalog.get_map(Match.map_id)
			var par := float(info["minutes"]) * 60.0
			Profile.grant_challenge(Match.map_id, Match.your_falls, Match.your_time, par)
		elif not Match.your_finished:
			Profile.last_xp = 0
			Profile.last_crown = 0
			Profile.last_bonuses = []
		Match.granted = true
	elif Match.practice:
		Match.granted = true
	elif Match.battle:
		if not Match.granted and Match.your_finished:
			var info := Catalog.get_map(Match.map_id)
			var par := float(info["minutes"]) * 60.0
			Profile.grant(Match.your_place, true, Match.your_falls, Match.your_time, par, Match.field_size, 0.5, false)
		elif not Match.your_finished:
			Profile.last_xp = 0
			Profile.last_crown = 0
			Profile.last_bonuses = []
		Match.granted = true
	elif not Match.granted:
		if not Match.ran and Match.series:
			Profile.last_xp = 0
			Profile.last_crown = 0
			Profile.last_bonuses = []
		else:
			var info := Catalog.get_map(Match.map_id)
			var par := float(info["minutes"]) * 60.0
			var trophy := not Match.series or Match.on_final()
			var round_index := Match.round_index if Match.series else -1
			Profile.grant(Match.your_place, Match.your_finished, Match.your_falls, Match.your_time, par, Match.field_size, 1.0, trophy, round_index)
		Match.granted = true


func _bonus_list() -> Control:
	var holder := CenterContainer.new()
	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(280, 0)
	column.add_theme_constant_override("separation", 2)
	for line in Profile.last_bonuses:
		var row := HBoxContainer.new()
		var bonus_name := ThemeLib.label(str(line["name"]), 18, Color("1c1915"))
		bonus_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		bonus_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var amount := ThemeLib.label("+%d" % int(line["xp"]), 18, Color("1c1915"))
		amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(bonus_name)
		row.add_child(amount)
		column.add_child(row)
	holder.add_child(column)
	return holder


func _rates_text() -> String:
	if Match.challenge:
		return "A first clear pays 100 XP. Finishing that roof again pays 25, plus 15 for no falls and 10 for the roof's time."
	if Match.battle:
		return "Battle pays half a lobby finish, rounded. Same place, clean run, and pace bonuses. No trophy."
	if Match.practice:
		return "Practice pays no XP and no trophies. A speedrun clock starts on RUN!. The ghost is your best time, see-through, and it will not bump you."
	if Match.series and not Match.on_final():
		return "This round pays for the place. Round 2 pays more than round 1, and the final pays the most. One crown, and only for the winner of the final."
	if Match.series:
		return "The final pays the most. Last standing takes one crown. 2nd through 5th are paid for the place."
	return "Finish +40. Win +110, 2nd +55, 3rd +35, 4th and 5th +25. No falls +35. Under the roof's time +20. A win still takes the trophy."


func _practice_headline() -> String:
	if Match.speedrun and Match.your_finished and Match.beat_pb:
		return "New personal best"
	if Match.speedrun and Match.your_finished:
		return "Short of your best"
	if Match.speedrun:
		return "No time"
	if Match.your_finished and Match.fill_bots and Match.your_place == 1:
		return "You won the practice"
	if Match.your_finished and Match.fill_bots:
		return "Finished %s" % _ordinal(Match.your_place)
	if Match.your_finished:
		return "Roof cleared"
	return "Practice over"


func _practice_reward() -> String:
	if not Match.speedrun:
		return "Practice pays no XP."
	if not Match.your_finished:
		return "Cross the line to keep a time."
	var clock := GhostStore.format_clock(Match.your_time)
	if Match.beat_pb and Match.previous_pb < 0.0:
		return "%s    ·    first best on this roof" % clock
	if Match.beat_pb:
		return "%s    ·    was %s" % [clock, GhostStore.format_clock(Match.previous_pb)]
	return "%s    ·    PB %s" % [clock, GhostStore.format_clock(Match.pb_time)]


func _again() -> void:
	Match.started = false
	Match.granted = false
	Match.results.clear()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Curtain.go("res://scenes/race.tscn", "Loading the roof.")


func _practice() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/practice.tscn")


func _challenge_list() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/challenge.tscn")


func _ordinal(n: int) -> String:
	if n == 1:
		return "1st"
	if n == 2:
		return "2nd"
	if n == 3:
		return "3rd"
	return "%dth" % n


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	if Match.challenge:
		_challenge_list()
	elif Match.practice:
		_practice()
	else:
		_menu()


func _next() -> void:
	if Match.series and Match.on_final():
		_menu()
		return
	if Match.series and not Match.through and not _hosting():
		_menu()
		return
	if not Network.is_online():
		_enter_next_vote()
		return
	if multiplayer.is_server():
		goto_vote.rpc()
	else:
		ask_vote.rpc_id(1)


func _host_left() -> void:
	Network.notice = "The host left the room."
	Network.offline()
	Curtain.go("res://scenes/menu.tscn", "Loading.")


func _hosting() -> bool:
	return Network.is_online() and multiplayer.is_server()


func _enter_next_vote() -> void:
	if Match.series and not Match.on_final() and not Match.advanced:
		Match.round_index += 1
		Match.advanced = true
	if Match.series and not Match.through and not _hosting():
		Network.notice = "Out of the bracket."
		_menu()
		return
	get_tree().change_scene_to_file("res://scenes/vote.tscn")


func _menu() -> void:
	Match.clear_series()
	if Network.is_online() and multiplayer.server_disconnected.is_connected(_host_left):
		multiplayer.server_disconnected.disconnect(_host_left)
	Network.offline()
	Curtain.go("res://scenes/menu.tscn", "Loading.")


@rpc("any_peer", "reliable")
func ask_vote() -> void:
	if multiplayer.is_server():
		goto_vote.rpc()


@rpc("authority", "call_local", "reliable")
func goto_vote() -> void:
	_enter_next_vote()
