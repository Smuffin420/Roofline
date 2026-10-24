extends CanvasLayer

var _panel: Control
var _caption: Label
var _percent: Label
var _fill: ColorRect
var _busy := false
var _hold := false
var _determinate := false
var _sweep := 0.0


func _ready() -> void:
	layer = 80
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.visible = false
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_panel)
	var bg := ColorRect.new()
	bg.color = Color("1c1915")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(center)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	var brand := Label.new()
	brand.text = "ROOFLINE"
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	brand.add_theme_font_size_override("font_size", 18)
	brand.add_theme_color_override("font_color", Color("e23b2f"))
	box.add_child(brand)
	_caption = Label.new()
	_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_font_size_override("font_size", 28)
	_caption.add_theme_color_override("font_color", Color("efe8dc"))
	box.add_child(_caption)
	_percent = Label.new()
	_percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_percent.add_theme_font_size_override("font_size", 16)
	_percent.add_theme_color_override("font_color", Color("5c564e"))
	_percent.text = "0%"
	box.add_child(_percent)
	var track := Control.new()
	track.custom_minimum_size = Vector2(320, 10)
	var groove := ColorRect.new()
	groove.color = Color("3a342c")
	groove.set_anchors_preset(Control.PRESET_FULL_RECT)
	track.add_child(groove)
	_fill = ColorRect.new()
	_fill.color = Color("e23b2f")
	_fill.anchor_right = 0.34
	_fill.anchor_bottom = 1.0
	track.add_child(_fill)
	box.add_child(track)
	center.add_child(box)


func _process(delta: float) -> void:
	if not _panel.visible or _determinate:
		return
	_sweep = fposmod(_sweep + delta * 0.7, 1.0)
	var width := 0.34
	var x := _sweep * (1.0 + width) - width
	_fill.anchor_left = clampf(x, 0.0, 1.0)
	_fill.anchor_right = clampf(x + width, 0.0, 1.0)


func go(path: String, line: String) -> void:
	if _busy:
		return
	_busy = true
	_hold = false
	_show(line, true)
	set_progress(0.0, line)
	await get_tree().process_frame
	await get_tree().process_frame
	set_progress(0.2, line)
	get_tree().change_scene_to_file(path)
	if not _hold:
		_hide()


func again(line: String) -> void:
	if _busy:
		return
	_busy = true
	_hold = false
	var mode := Input.mouse_mode
	_show(line, false)
	set_progress(0.0, line)
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().reload_current_scene()
	Input.mouse_mode = mode
	if not _hold:
		_hide()


func keep() -> void:
	_hold = true


func set_progress(amount: float, line: String = "") -> void:
	_determinate = true
	if _panel:
		_panel.visible = true
	if line != "" and _caption:
		_caption.text = line
	var t := clampf(amount, 0.0, 1.0)
	if _fill:
		_fill.anchor_left = 0.0
		_fill.anchor_right = maxf(t, 0.02)
	if _percent:
		_percent.text = "%d%%" % int(round(t * 100.0))


func finish() -> void:
	set_progress(1.0)
	_hide()


func _show(line: String, free_mouse: bool) -> void:
	_caption.text = line
	_panel.visible = true
	if free_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _hide() -> void:
	_panel.visible = false
	_busy = false
	_hold = false
	_determinate = false
