extends Control

const Catalog := preload("res://scripts/catalog.gd")
const ThemeLib := preload("res://scripts/theme.gd")
const GhostStore := preload("res://scripts/ghosts.gd")
const Shots := preload("res://scripts/shots.gd")

var cards := {}
var selected := "annex"
var speedrun_on := false
var bots_on := false
var blurb: Label
var best: Label
var speed_button: Button
var bots_button: Button


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	theme = ThemeLib.make()
	speedrun_on = Match.speedrun
	bots_on = Match.fill_bots
	for map in Catalog.all():
		if str(map["id"]) == Match.map_id:
			selected = Match.map_id

	var bg := ColorRect.new()
	bg.color = Color("efe8dc")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 36
	root.offset_top = 20
	root.offset_right = -36
	root.offset_bottom = -16
	root.add_theme_constant_override("separation", 6)
	add_child(root)

	var battle_pick := Match.picking_battle
	root.add_child(ThemeLib.label("BATTLE" if battle_pick else "PRACTICE", 18, Color("e23b2f")))
	var title := ThemeLib.label("Pick a roof. Boxes on the line." if battle_pick else "Pick a roof and run it.", 36, Color("1c1915"))
	root.add_child(title)
	blurb = ThemeLib.label("", 16, Color("3c3832"))
	root.add_child(blurb)
	best = ThemeLib.label("", 16, Color("5c564e"))
	root.add_child(best)

	var grid := GridContainer.new()
	grid.columns = 5
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	root.add_child(grid)

	var picked: Array[Button] = []
	for map in Catalog.all():
		var id := str(map["id"])
		var button := Shots.card(str(map["name"]))
		button.pressed.connect(_select.bind(id))
		grid.add_child(button)
		cards[id] = button
		picked.append(button)

	var toggles := HBoxContainer.new()
	toggles.add_theme_constant_override("separation", 12)
	root.add_child(toggles)
	speed_button = _toggle("Speedrun", _on_speed)
	bots_button = _toggle("Fill lobby with bots", _on_bots)
	toggles.add_child(speed_button)
	toggles.add_child(bots_button)

	var note := ThemeLib.label("One item at a time. F, right click, or B uses it. A battle pays no XP." if battle_pick else "Speedrun starts the clock on RUN!. Your best time comes back as a ghost you can run through.", 15, Color("5c564e"))
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(note)

	var start := ThemeLib.button("Start battle" if battle_pick else "Start run", _start)
	root.add_child(start)
	var back := ThemeLib.button("Back", _menu)
	root.add_child(back)

	_wire_grid(picked, start if battle_pick else speed_button)
	if battle_pick:
		speed_button.visible = false
		bots_button.visible = false
		best.visible = false
		start.focus_neighbor_bottom = start.get_path_to(back)
		back.focus_neighbor_top = back.get_path_to(start)
	else:
		speed_button.focus_neighbor_right = speed_button.get_path_to(bots_button)
		speed_button.focus_neighbor_bottom = speed_button.get_path_to(start)
		bots_button.focus_neighbor_left = bots_button.get_path_to(speed_button)
		bots_button.focus_neighbor_bottom = bots_button.get_path_to(start)
		start.focus_neighbor_top = start.get_path_to(speed_button)
		start.focus_neighbor_bottom = start.get_path_to(back)
		back.focus_neighbor_top = back.get_path_to(start)

	_paint()
	_show_selected()
	var ids: Array = []
	for map in Catalog.all():
		ids.append(str(map["id"]))
	Shots.request(self, ids, _on_shot)
	if picked.size() > 0:
		var opener: Button = cards[selected] if cards.has(selected) else picked[0]
		opener.call_deferred("grab_focus")


func _toggle(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	button.pressed.connect(callback)
	return button


func _paint() -> void:
	_paint_toggle(speed_button, "Speedrun", speedrun_on)
	_paint_toggle(bots_button, "Fill lobby with bots", bots_on)


func _paint_toggle(button: Button, caption: String, on: bool) -> void:
	button.text = "%s    ·    %s" % [caption, "On" if on else "Off"]
	var ink := Color("e23b2f") if on else Color("efe8dc")
	button.add_theme_color_override("font_color", ink)
	button.add_theme_color_override("font_hover_color", Color("efe8dc"))
	button.add_theme_color_override("font_focus_color", Color("efe8dc"))
	button.add_theme_color_override("font_pressed_color", Color("efe8dc"))


func _select(id: String) -> void:
	if not cards.has(id):
		return
	selected = id
	_show_selected()


func _show_selected() -> void:
	for key in cards.keys():
		Shots.mark(cards[key], str(key) == selected)
	var map := Catalog.get_map(selected)
	blurb.text = str(map["blurb"])
	var pb := GhostStore.best_time(selected)
	if pb < 0.0:
		best.text = "%s has no personal best yet." % str(map["name"])
	else:
		best.text = "%s personal best  %s" % [str(map["name"]), GhostStore.format_clock(pb)]


func _on_shot(id: String, tex: Texture2D) -> void:
	if cards.has(id):
		Shots.fill(cards[id], tex)


func _on_speed() -> void:
	speedrun_on = not speedrun_on
	_paint()


func _on_bots() -> void:
	bots_on = not bots_on
	_paint()


func _start() -> void:
	Network.offline()
	Match.audit = false
	if Match.picking_battle:
		Match.begin_battle(selected)
		Curtain.go("res://scenes/race.tscn", "Loading the roof.")
		return
	Match.begin_race(selected)
	Match.practice = true
	Match.speedrun = speedrun_on
	Match.fill_bots = bots_on
	Curtain.go("res://scenes/race.tscn", "Loading the roof.")


func _menu() -> void:
	Match.picking_battle = false
	Curtain.go("res://scenes/menu.tscn", "Loading.")


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	_menu()


func _wire_grid(picked: Array[Button], below: Control) -> void:
	var cols := 5
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
		button.focus_neighbor_left = button.get_path_to(picked[left_i])
		button.focus_neighbor_right = button.get_path_to(picked[right_i])
		button.focus_neighbor_top = button.get_path_to(picked[up_i])
		if down_i >= count:
			button.focus_neighbor_bottom = button.get_path_to(below)
		else:
			button.focus_neighbor_bottom = button.get_path_to(picked[down_i])
	below.focus_neighbor_top = below.get_path_to(picked[mini(cols, count - 1)])
