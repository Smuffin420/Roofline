extends Control

const FADE_IN := 0.28
const HOLD := 1.15
const FADE_OUT := 0.28

var _age := 0.0
var _gone := false
var _card: CanvasItem


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var stack := Control.new()
	stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg := ColorRect.new()
	bg.color = Color(0.64, 0.69, 0.73)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	stack.add_child(bg)
	var frame := TextureRect.new()
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.texture = load("res://Assets/Logos/altf4.jpg") as Texture2D
	stack.add_child(frame)
	add_child(stack)
	frame.call_deferred("set_anchors_and_offsets_preset", Control.PRESET_FULL_RECT)
	_card = stack
	_card.modulate.a = 0.0
	preload("res://scripts/styles.gd").request(Profile.style_id())
	if _hurry():
		_gone = true
		Curtain.go("res://scenes/menu.tscn", "Loading.")


func _process(delta: float) -> void:
	if _gone:
		return
	_age += delta
	var fade_in := clampf(_age / FADE_IN, 0.0, 1.0)
	var fade_out := 1.0
	if _age > FADE_IN + HOLD:
		fade_out = clampf(1.0 - (_age - FADE_IN - HOLD) / FADE_OUT, 0.0, 1.0)
	_card.modulate.a = fade_in * fade_out
	if _age >= FADE_IN + HOLD + FADE_OUT:
		_gone = true
		Curtain.go("res://scenes/menu.tscn", "Loading.")


func _hurry() -> bool:
	for key in ["ROOFLINE_BOT", "ROOFLINE_BATTLE", "ROOFLINE_BATTLE_CHECK", "ROOFLINE_HOST", "ROOFLINE_JOIN"]:
		if OS.get_environment(key) == "1":
			return true
	return false
