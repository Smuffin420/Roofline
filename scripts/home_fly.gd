extends TextureRect

const STEP := 1.0 / 12.0

var _jpg: PackedByteArray
var _sizes: PackedInt32Array
var _offsets: PackedInt32Array
var _i := 0
var _wait := 0.0
var _tex: ImageTexture


func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	call_deferred("_cover")
	var reel: Resource = load("res://Assets/menu/home_fly.res") as Resource
	if reel == null:
		return
	_jpg = reel.get("jpg")
	_sizes = reel.get("sizes")
	var at := 0
	for n in _sizes.size():
		_offsets.append(at)
		at += int(_sizes[n])
	_tex = ImageTexture.new()
	_show_frame(0)
	texture = _tex


func _cover() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _process(delta: float) -> void:
	if _sizes.is_empty() or _tex == null:
		return
	_wait += delta
	if _wait < STEP:
		return
	_wait = 0.0
	_i = (_i + 1) % _sizes.size()
	_show_frame(_i)


func _show_frame(i: int) -> void:
	var img := Image.new()
	var off := int(_offsets[i])
	var n := int(_sizes[i])
	if img.load_jpg_from_buffer(_jpg.slice(off, off + n)) != OK:
		return
	if _tex.get_width() == 0:
		_tex.set_image(img)
	else:
		_tex.update(img)
