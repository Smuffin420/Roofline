extends RefCounted


static func make() -> Theme:
	var ui := Theme.new()
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("1c1915")
	normal.set_corner_radius_all(2)
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	var hover := normal.duplicate()
	hover.bg_color = Color("e23b2f")
	var pressed := normal.duplicate()
	pressed.bg_color = Color("9d241c")
	ui.set_stylebox("normal", "Button", normal)
	ui.set_stylebox("hover", "Button", hover)
	ui.set_stylebox("pressed", "Button", pressed)
	ui.set_stylebox("focus", "Button", hover)
	ui.set_color("font_color", "Button", Color("efe8dc"))
	ui.set_color("font_hover_color", "Button", Color("efe8dc"))
	ui.set_color("font_pressed_color", "Button", Color("efe8dc"))
	ui.set_color("font_focus_color", "Button", Color("efe8dc"))
	ui.set_font_size("font_size", "Button", 20)
	var field := StyleBoxFlat.new()
	field.bg_color = Color("fffdf8")
	field.border_color = Color("1c1915")
	field.set_border_width_all(2)
	field.set_corner_radius_all(2)
	field.content_margin_top = 8
	field.content_margin_bottom = 8
	field.content_margin_left = 12
	field.content_margin_right = 12
	ui.set_stylebox("normal", "LineEdit", field)
	ui.set_stylebox("focus", "LineEdit", field)
	ui.set_color("font_color", "LineEdit", Color("1c1915"))
	ui.set_color("font_placeholder_color", "LineEdit", Color("8a8175"))
	ui.set_font_size("font_size", "LineEdit", 18)
	var track := StyleBoxFlat.new()
	track.bg_color = Color(0, 0, 0, 0)
	track.content_margin_top = 10
	track.content_margin_bottom = 10
	ui.set_stylebox("slider", "HSlider", track)
	var grab := StyleBoxFlat.new()
	grab.bg_color = Color(0, 0, 0, 0)
	ui.set_stylebox("grabber_area", "HSlider", grab)
	ui.set_stylebox("grabber_area_highlight", "HSlider", grab)
	var knob := _knob(Color("1c1915"))
	ui.set_icon("grabber", "HSlider", knob)
	ui.set_icon("grabber_highlight", "HSlider", _knob(Color("e23b2f")))
	return ui


static func _knob(color: Color) -> Texture2D:
	var image := Image.create(22, 34, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in 34:
		for x in 22:
			if x < 2 or x > 19 or y < 2 or y > 31:
				continue
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


static func button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 48)
	button.pressed.connect(func() -> void: Sfx.play("click", -8.0))
	button.pressed.connect(callback)
	return button


static func label(text: String, size: int, color: Color) -> Label:
	var node := Label.new()
	node.text = text
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_theme_font_size_override("font_size", size)
	node.add_theme_color_override("font_color", color)
	return node


static func bar(fraction: float, width: float) -> Control:
	var bg := ColorRect.new()
	bg.custom_minimum_size = Vector2(width, 10)
	bg.color = Color("d9d0c3")
	var fill := ColorRect.new()
	fill.color = Color("e23b2f")
	fill.custom_minimum_size = Vector2(width * clampf(fraction, 0.0, 1.0), 10)
	bg.add_child(fill)
	return bg
