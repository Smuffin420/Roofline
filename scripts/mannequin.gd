extends Node3D

const Styles = preload("res://scripts/styles.gd")

var tint := Color("e23b2f")
var name_text := "Runner"
var name_size := 56

var _body: Array[MeshInstance3D] = []
var _joints: Array[MeshInstance3D] = []
var name_tag: Label3D
var _out_tag: Label3D
var hat_id := "cap"
var style_id := "bulbous"
var trail_id := "off"
var trail_preview := false

var rig: Node3D
var _head: Node3D
var _hat_root: Node3D
var _hat_meshes: Array[MeshInstance3D] = []
var _fixed: Array[MeshInstance3D] = []
var _ghost_alpha := -1.0
var hips: Node3D
var chest: Node3D
var thigh_l: Node3D
var thigh_r: Node3D
var shin_l: Node3D
var shin_r: Node3D
var arm_l: Node3D
var arm_r: Node3D
var fore_l: Node3D
var fore_r: Node3D
var _pelvis: MeshInstance3D
var _torso: MeshInstance3D
var _collar: MeshInstance3D
var _neck: MeshInstance3D
var _skull: MeshInstance3D
var _visor: MeshInstance3D
var _thigh_l: MeshInstance3D
var _thigh_r: MeshInstance3D
var _shin_l: MeshInstance3D
var _shin_r: MeshInstance3D
var _shoe_l: MeshInstance3D
var _shoe_r: MeshInstance3D
var _arm_l: MeshInstance3D
var _arm_r: MeshInstance3D
var _fore_l: MeshInstance3D
var _fore_r: MeshInstance3D
var _hand_l: MeshInstance3D
var _hand_r: MeshInstance3D
var _ears: Node3D
var _eyes: Node3D
var _tail: Node3D
var _trail

var _mascot: Node3D
var _mascot_anim: AnimationPlayer
var _spine: Skeleton3D
var _spine_bone := -1
const _RUN_CLIP := "Running"
const _SLIDE_CLIP := "slide_light"
const _WIN_CLIP := "FunnyDancing_02"
const _MARK_CLIPS: Array[String] = ["Wave_for_Help_3", "FunnyDancing_02", "Hello_Run"]
const _SLIDE_LOOP_FROM := 0.45
const _SLIDE_LOOP_TO := 0.78
static var _slide_donor: Animation
static var _win_donor: Animation
static var _mark_bank := {}

var _cycle := 0.0
var _clock := 0.0
var _land := 0.0
var _prev := Vector3.ZERO
var _has_prev := false
var _speed := 0.0
var _vy := 0.0
var _grounded := true
var _fp := false
var _saw_slide := false
var _fp_mat: ShaderMaterial
var _head_mat: ShaderMaterial
var _arms_measured := false
var _body_wait := false
var _arm_upper_l := 0.0
var _arm_lower_l := 0.0
var _arm_upper_r := 0.0
var _arm_lower_r := 0.0


func set_tint(color: Color) -> void:
	tint = color
	for mesh in _body:
		mesh.material_override = _mat(color, 0.72)
	for mesh in _joints:
		mesh.material_override = _mat(color.darkened(0.45), 0.8)
	if name_tag:
		name_tag.modulate = Color(0.98, 0.96, 0.92)
		name_tag.outline_modulate = color.darkened(0.25)


func set_name_text(text: String) -> void:
	name_text = text
	if name_tag:
		name_tag.text = text
		var size := name_size
		if text.length() > 8:
			size = maxi(28, int(float(name_size) * 8.0 / float(text.length())))
		name_tag.font_size = size


func _ready() -> void:
	# Runs after the mascot's animation so first-person arms can be posed on top.
	process_priority = 10
	rig = _pivot(self, Vector3.ZERO)
	hips = _pivot(rig, Vector3.ZERO)
	_pelvis = _box(hips, Vector3(0, 0.82, 0), Vector3(0.38, 0.14, 0.2), true)
	thigh_l = _leg(hips, -1)
	thigh_r = _leg(hips, 1)
	chest = _pivot(rig, Vector3(0, 0.9, 0))
	_torso = _box(chest, Vector3(0, 0.24, 0), Vector3(0.34, 0.46, 0.2), false)
	_collar = _box(chest, Vector3(0, 0.5, 0), Vector3(0.58, 0.1, 0.16), true)
	_neck = _box(chest, Vector3(0, 0.62, 0), Vector3(0.1, 0.1, 0.1), true)
	_head = _pivot(chest, Vector3(0, 0.8, 0))
	_skull = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	_skull.mesh = sphere
	_head.add_child(_skull)
	_body.append(_skull)
	_visor = MeshInstance3D.new()
	var visor_mesh := BoxMesh.new()
	visor_mesh.size = Vector3(0.22, 0.05, 0.045)
	_visor.mesh = visor_mesh
	_visor.position = Vector3(0, 0.02, -0.135)
	_visor.material_override = _mat(Color("141210"), 0.28)
	_head.add_child(_visor)
	_fixed.append(_visor)
	_ears = _pivot(_head, Vector3.ZERO)
	_ear(_ears, -1)
	_ear(_ears, 1)
	_eyes = _pivot(_head, Vector3.ZERO)
	_eye(_eyes, -1)
	_eye(_eyes, 1)
	_ears.visible = false
	_eyes.visible = false
	arm_l = _arm(chest, -1)
	arm_r = _arm(chest, 1)
	_tail = _pivot(hips, Vector3(0, 0.92, 0.08))
	_box(_tail, Vector3(0, 0.04, 0.14), Vector3(0.06, 0.06, 0.22), false)
	var tail_tip := _pivot(_tail, Vector3(0, 0.06, 0.26))
	_box(tail_tip, Vector3(0, 0.02, 0.12), Vector3(0.045, 0.045, 0.18), false)
	_tail.visible = false

	name_tag = Label3D.new()
	name_tag.text = name_text
	name_tag.font_size = name_size
	name_tag.pixel_size = 0.004
	name_tag.position = Vector3(0, 0.54, 0)
	name_tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_tag.modulate = Color(0.98, 0.96, 0.92)
	name_tag.outline_size = 16
	name_tag.outline_modulate = tint.darkened(0.25)
	name_tag.no_depth_test = true
	name_tag.render_priority = 8
	_head.add_child(name_tag)
	_apply_style()
	set_name_text(name_text)
	_trail = load("res://scripts/trail.gd").new()
	_trail.trail_id = trail_id
	_trail.preview_pose = trail_preview
	_trail.position = Vector3(0, 1.05, 0.22)
	add_child(_trail)
	Styles.request(style_id)
	if rig:
		rig.visible = false
	_body_wait = true


func _attach_mascot() -> void:
	var packed := Styles.scene_for(style_id)
	if packed == null:
		return
	_mascot = packed.instantiate()
	_mascot.name = "Mascot"
	_mascot.rotation.y = PI
	add_child(_mascot)
	_mascot_anim = _mascot.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_spine = _mascot.find_child("Skeleton3D", true, false) as Skeleton3D
	_spine_bone = _spine.find_bone("mixamorig_Spine2") if _spine != null else -1
	_prepare_clips()
	_arms_measured = false
	if rig:
		rig.visible = false
	var holder := get_parent()
	if holder != null and holder.has_method("_sync_block_hands"):
		holder._sync_block_hands()
	if name_tag and name_tag.get_parent() != self:
		name_tag.reparent(self)
		name_tag.position = Vector3(0, 1.95, 0)


func _swap_mascot() -> void:
	var stale: Array[Node] = []
	for child in get_children():
		if child == _mascot or str(child.name) == "Mascot":
			stale.append(child)
	for child in stale:
		remove_child(child)
		child.free()
	_mascot = null
	_mascot_anim = null
	_spine = null
	_spine_bone = -1
	_arms_measured = false
	_fp_mat = null
	_head_mat = null
	_attach_mascot()


func _prepare_clips() -> void:
	if _mascot_anim == null:
		return
	if _mascot_anim.has_animation(_RUN_CLIP):
		var run := _mascot_anim.get_animation(_RUN_CLIP)
		if run:
			run.loop_mode = Animation.LOOP_LINEAR
	# The home screen only needs the body you picked. Slide and win clips
	# come from two other characters, so wait until a runner is in a race.
	var parent := get_parent()
	if parent != null and parent.has_method("is_local"):
		_ensure_slide()
		_ensure_win()
		_ensure_marks()


func _pin_hips() -> void:
	if _mascot:
		_mascot.position = Vector3.ZERO
	if _spine == null:
		return
	var hips := _spine.find_bone("mixamorig_Hips")
	if hips < 0:
		return
	var pose := _spine.get_bone_pose(hips)
	var rest := _spine.get_bone_rest(hips)
	pose.origin.x = rest.origin.x
	pose.origin.z = rest.origin.z
	var parent := get_parent()
	if parent != null and "plant" in parent and bool(parent.plant):
		pose.origin.y = rest.origin.y
	_spine.set_bone_pose(hips, pose)


func _donor_slide() -> Animation:
	if _slide_donor != null:
		return _slide_donor
	var packed := Styles.scene_for("chill")
	if packed == null:
		return _slide_donor
	var node := packed.instantiate()
	var player := node.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player and player.has_animation(_SLIDE_CLIP):
		_slide_donor = player.get_animation(_SLIDE_CLIP)
	if node.get_parent():
		node.get_parent().remove_child(node)
	node.free()
	return _slide_donor


func _bake_slide(clip: Animation) -> void:
	var hips := NodePath("target_character/Skeleton3D:mixamorig_Hips")
	var idx := clip.find_track(hips, Animation.TYPE_POSITION_3D)
	if idx >= 0 and clip.track_get_key_count(idx) > 0:
		var origin: Vector3 = clip.track_get_key_value(idx, 0)
		for key in clip.track_get_key_count(idx):
			var pos: Vector3 = clip.track_get_key_value(idx, key)
			pos.x = origin.x
			pos.z = origin.z
			clip.track_set_key_value(idx, key, pos)


func _ensure_slide() -> void:
	if _mascot_anim == null or _mascot_anim.has_animation(_SLIDE_CLIP):
		var slide := _mascot_anim.get_animation(_SLIDE_CLIP) if _mascot_anim != null else null
		if slide and not slide.has_meta("roofline_slide"):
			_bake_slide(slide)
			slide.set_meta("roofline_slide", true)
		return
	var donated := _donor_slide()
	if donated == null:
		return
	_mascot_anim.get_animation_library("").add_animation(_SLIDE_CLIP, donated.duplicate())
	var fresh := _mascot_anim.get_animation(_SLIDE_CLIP)
	if fresh and not fresh.has_meta("roofline_slide"):
		_bake_slide(fresh)
		fresh.set_meta("roofline_slide", true)


func _ensure_marks() -> void:
	if _mascot_anim == null:
		return
	for clip_name in _MARK_CLIPS:
		if not _mascot_anim.has_animation(clip_name):
			var donated := _mark_bank_clip(clip_name)
			if donated == null:
				continue
			_mascot_anim.get_animation_library("").add_animation(clip_name, donated.duplicate())
		var clip := _mascot_anim.get_animation(clip_name)
		if clip and not clip.has_meta("roofline_mark"):
			_bake_slide(clip)
			clip.loop_mode = Animation.LOOP_LINEAR
			clip.set_meta("roofline_mark", true)


func _mark_bank_clip(id: String) -> Animation:
	if _mark_bank.has(id):
		return _mark_bank[id]
	if not _mark_bank.is_empty():
		return null
	var packed := Styles.scene_for("bulbous")
	if packed == null:
		return null
	var node := packed.instantiate()
	var player := node.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player:
		for clip_name in _MARK_CLIPS:
			if player.has_animation(clip_name):
				_mark_bank[clip_name] = player.get_animation(clip_name)
	if node.get_parent():
		node.get_parent().remove_child(node)
	node.free()
	return _mark_bank.get(id) as Animation


func _mark_slot() -> int:
	var parent := get_parent()
	if parent != null and "spawn_slot" in parent:
		return int(parent.spawn_slot)
	return 0


func _mark_clip() -> String:
	return _MARK_CLIPS[posmod(_mark_slot(), _MARK_CLIPS.size())]


func _mark_pose() -> String:
	match _mark_clip():
		"FunnyDancing_02":
			return "dance"
		"Hello_Run":
			return "cheer"
		_:
			return "wave"


func _emote_clip(id: String) -> String:
	match id:
		"wave", "bow":
			return "Wave_for_Help_3"
		"dance", "spin":
			return "FunnyDancing_02"
		"cheer", "flex":
			return "Hello_Run"
		_:
			return ""


func _play_mark(clip_name: String) -> void:
	if not _mascot_anim.has_animation(clip_name):
		clip_name = _RUN_CLIP
	if _mascot_anim.current_animation != clip_name or not _mascot_anim.is_playing():
		_mascot_anim.play(clip_name, 0.2)
		var clip := _mascot_anim.get_animation(clip_name)
		if clip != null and clip.length > 0.2 and clip_name != _RUN_CLIP:
			_mascot_anim.seek(fmod(float(_mark_slot()) * 0.37, clip.length), true)
	_mascot_anim.speed_scale = 1.0
	_pin_hips()


func _ensure_win() -> void:
	if _mascot_anim == null:
		return
	if not _mascot_anim.has_animation(_WIN_CLIP):
		var donated := _donor_win()
		if donated == null:
			return
		_mascot_anim.get_animation_library("").add_animation(_WIN_CLIP, donated.duplicate())
	var clip := _mascot_anim.get_animation(_WIN_CLIP)
	if clip and not clip.has_meta("roofline_win"):
		_bake_slide(clip)
		clip.loop_mode = Animation.LOOP_LINEAR
		clip.set_meta("roofline_win", true)


func _donor_win() -> Animation:
	if _win_donor != null:
		return _win_donor
	var packed := Styles.scene_for("bulbous")
	if packed == null:
		return _win_donor
	var node := packed.instantiate()
	var player := node.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player and player.has_animation(_WIN_CLIP):
		_win_donor = player.get_animation(_WIN_CLIP)
	if node.get_parent():
		node.get_parent().remove_child(node)
	node.free()
	return _win_donor


func _won_pose() -> bool:
	var parent := get_parent()
	if parent == null or not ("won" in parent):
		return false
	if not bool(parent.won) or not bool(parent.finished):
		return false
	if _fp:
		return false
	if float(parent.glide_left) > 0.0:
		return false
	return _speed < 2.4


func _drive_mascot(delta: float) -> void:
	if _mascot == null:
		return
	_mascot.visible = true
	if _mascot_anim == null or not _mascot_anim.has_animation(_RUN_CLIP):
		return
	if _flag("on_marks"):
		_ensure_marks()
		_play_mark(_mark_clip())
		return
	var emote := _parent_emote()
	if emote != "":
		var clip_name := _emote_clip(emote)
		if clip_name != "":
			_ensure_marks()
			if _mascot_anim.has_animation(clip_name):
				_play_mark(clip_name)
				return
	if _won_pose() and _mascot_anim.has_animation(_WIN_CLIP):
		if _mascot_anim.current_animation != _WIN_CLIP or not _mascot_anim.is_playing():
			_mascot_anim.play(_WIN_CLIP, 0.2)
		_mascot_anim.speed_scale = 1.15
		_pin_hips()
		return
	if _flag("hanging") or _flag("zipping"):
		if _mascot_anim.is_playing():
			_mascot_anim.stop(true)
		if _flag("zipping"):
			_reach(Vector3(-0.16, 1.78, -0.08), Vector3(0.16, 1.78, -0.08))
		else:
			_reach(Vector3(-0.2, 1.64, -0.58), Vector3(0.2, 1.64, -0.58))
		return
	var wall_side := _wall()
	if wall_side != 0:
		if _mascot_anim.current_animation != _RUN_CLIP or not _mascot_anim.is_playing():
			_mascot_anim.play(_RUN_CLIP, 0.12)
		_mascot_anim.speed_scale = 1.15
		var scrape := sin(_clock * 14.0) * 0.06
		if wall_side < 0:
			_reach(Vector3(-0.66, 1.28, -0.22), Vector3(0.3, 1.08 + scrape, -0.38))
		else:
			_reach(Vector3(-0.3, 1.08 + scrape, -0.38), Vector3(0.66, 1.28, -0.22))
		return
	if _flag("stunned"):
		if _mascot_anim.is_playing():
			_mascot_anim.stop(true)
		_flinch()
		_reach(Vector3(-0.42, 1.2, 0.38), Vector3(0.42, 1.2, 0.38))
		return
	if _flag("sliding") and _mascot_anim.has_animation(_SLIDE_CLIP):
		if _mascot_anim.current_animation != _SLIDE_CLIP or not _mascot_anim.is_playing():
			if _fp:
				_mascot_anim.play(_SLIDE_CLIP, 0.0)
				_mascot_anim.seek(_SLIDE_LOOP_FROM, true)
			else:
				_mascot_anim.play(_SLIDE_CLIP, 0.12)
		elif _mascot_anim.current_animation_position >= _SLIDE_LOOP_TO:
			_mascot_anim.seek(_SLIDE_LOOP_FROM, true)
		_mascot_anim.speed_scale = 1.0
		if _fp:
			# The slide clip reaches the hands past the lens. Hold them back.
			_reach(Vector3(-0.62, 0.42, 0.48), Vector3(0.62, 0.42, 0.48))
		return
	var running := _grounded and _speed > 2.2 and _wall() == 0
	if running or trail_preview:
		if _mascot_anim.current_animation != _RUN_CLIP or not _mascot_anim.is_playing():
			var blend := 0.0 if _fp and _mascot_anim.current_animation == _SLIDE_CLIP else 0.18
			_mascot_anim.play(_RUN_CLIP, blend)
		var goal := 1.0 if trail_preview and not running else clampf(_speed / 8.0, 0.75, 1.35)
		_mascot_anim.speed_scale = lerpf(_mascot_anim.speed_scale, goal, 1.0 - exp(-6.0 * delta))
	elif _mascot_anim.is_playing():
		_mascot_anim.stop()


func _seat_name() -> void:
	if name_tag == null or name_tag.get_parent() != self or trail_preview:
		return
	var y := 2.15
	if _spine != null:
		var bone := _spine.find_bone("mixamorig_Head")
		if bone >= 0:
			var world: Vector3 = _spine.global_transform * _spine.get_bone_global_pose(bone).origin
			var local: Vector3 = global_transform.affine_inverse() * world
			y = local.y + 0.46
	name_tag.position = Vector3(0.0, y + sin(_clock * 2.3) * 0.04, 0.0)
	name_tag.pixel_size = 0.0065


func show_eliminated() -> void:
	if _out_tag != null:
		_out_tag.visible = true
		return
	_out_tag = Label3D.new()
	_out_tag.text = "Eliminated"
	_out_tag.font_size = 64
	_out_tag.pixel_size = 0.012
	_out_tag.modulate = Color("e23b2f")
	_out_tag.outline_size = 22
	_out_tag.outline_modulate = Color("1c1915")
	_out_tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_out_tag.no_depth_test = true
	_out_tag.render_priority = 10
	_out_tag.position = Vector3(0.0, 2.55, 0.0)
	add_child(_out_tag)


func _seat_eliminated() -> void:
	if _out_tag == null:
		return
	var y := 2.55
	if name_tag != null and name_tag.get_parent() == self:
		y = name_tag.position.y + 0.48
	_out_tag.position = Vector3(0.0, y, 0.0)


func _seat_trail() -> void:
	if _trail == null:
		return
	var back := Vector3(0.0, 1.05, 0.22)
	if _spine != null and _spine_bone >= 0:
		var world: Vector3 = _spine.global_transform * _spine.get_bone_global_pose(_spine_bone).origin
		var local: Vector3 = global_transform.affine_inverse() * world
		# The face is toward -Z. Sit the trail on the center of the back.
		back = Vector3(0.0, local.y, local.z + 0.34)
	_trail.position = back


func _leg(parent: Node3D, side: int) -> Node3D:
	var hip := _pivot(parent, Vector3(float(side) * 0.15, 0.78, 0))
	var thigh := _box(hip, Vector3(0, -0.21, 0), Vector3(0.13, 0.42, 0.15), false)
	var knee := _pivot(hip, Vector3(0, -0.42, 0))
	var shin := _box(knee, Vector3(0, -0.18, 0), Vector3(0.12, 0.36, 0.14), false)
	var shoe := _box(knee, Vector3(0, -0.38, -0.07), Vector3(0.13, 0.08, 0.28), true)
	if side < 0:
		shin_l = knee
		_thigh_l = thigh
		_shin_l = shin
		_shoe_l = shoe
	else:
		shin_r = knee
		_thigh_r = thigh
		_shin_r = shin
		_shoe_r = shoe
	return hip


func _arm(parent: Node3D, side: int) -> Node3D:
	var shoulder := _pivot(parent, Vector3(float(side) * 0.34, 0.46, 0))
	var upper := _box(shoulder, Vector3(0, -0.15, 0), Vector3(0.1, 0.3, 0.1), false)
	var elbow := _pivot(shoulder, Vector3(0, -0.3, 0))
	var fore := _box(elbow, Vector3(0, -0.13, 0), Vector3(0.09, 0.26, 0.09), false)
	var hand := _box(elbow, Vector3(0, -0.28, -0.02), Vector3(0.08, 0.07, 0.1), false)
	if side < 0:
		fore_l = elbow
		_arm_l = upper
		_fore_l = fore
		_hand_l = hand
	else:
		fore_r = elbow
		_arm_r = upper
		_fore_r = fore
		_hand_r = hand
	return shoulder


func _process(delta: float) -> void:
	if _body_wait:
		_attach_mascot()
		if _mascot != null:
			_body_wait = false
	if rig == null:
		return
	if _mascot:
		rig.visible = false
	if is_inside_tree() and not is_visible_in_tree():
		return
	_clock += delta
	_sample(delta)
	if _grounded and _speed > 1.4 and not _flag("sliding") and _wall() == 0:
		_cycle += delta * _speed * 1.65
	elif _wall() != 0:
		_cycle += delta * 13.0
	var pose := _pose()
	var on_slide := _flag("sliding") and _grounded
	var weight := 1.0 - exp(-12.0 * delta)
	# First person: blending the body through the low camera fills the lens.
	# Snap into the slide, and snap back out. Third person keeps the blend.
	if _fp and on_slide != _saw_slide:
		weight = 1.0
	elif _fp and float(pose["drop"]) > rig.position.y + 0.2:
		weight = 1.0
	_saw_slide = on_slide
	if str(_parent_emote()) == "spin":
		rig.rotation.y += delta * 5.5
	else:
		rig.rotation.y = lerp_angle(rig.rotation.y, 0.0, weight)
	_blend(thigh_l, pose["thigh_l"], weight)
	_blend(thigh_r, pose["thigh_r"], weight)
	_blend(shin_l, pose["shin_l"], weight)
	_blend(shin_r, pose["shin_r"], weight)
	_blend(arm_l, pose["arm_l"], weight)
	_blend(arm_r, pose["arm_r"], weight)
	_blend(fore_l, pose["fore_l"], weight)
	_blend(fore_r, pose["fore_r"], weight)
	_blend(chest, pose["chest"], weight)
	_blend(hips, pose["hips"], weight)
	var head_aim: Vector3 = pose["head"] if pose.has("head") else Vector3.ZERO
	_blend(_head, head_aim, weight)
	rig.position.y = lerpf(rig.position.y, float(pose["drop"]), weight)
	rig.rotation.z = lerp_angle(rig.rotation.z, float(pose["lean"]), weight)
	if _tail != null and style_id == "cat":
		_tail.rotation.y = sin(_clock * 3.2) * 0.55
		_tail.rotation.x = -0.35 + sin(_clock * 2.1) * 0.08
	_drive_mascot(delta)
	_seat_trail()
	_seat_name()
	_seat_eliminated()
	if _fp:
		_pose_fp_arms()
		_cull_near_camera()


func _sample(delta: float) -> void:
	var parent := get_parent()
	var local := false
	if parent != null and parent.has_method("is_local"):
		local = bool(parent.is_local())
	if local and parent.has_method("horizontal_speed"):
		_speed = float(parent.horizontal_speed())
		_vy = float(parent.velocity.y)
		_grounded = bool(parent.is_on_floor())
	elif is_inside_tree():
		if _has_prev and delta > 0.0:
			var step := global_position - _prev
			if step.length() < 8.0:
				_speed = Vector2(step.x, step.z).length() / delta
				_vy = step.y / delta
			else:
				_speed = 0.0
				_vy = 0.0
		var wall := _wall()
		var hanging := _flag("hanging")
		_grounded = absf(_vy) < 3.2 and wall == 0 and not hanging
		_prev = global_position
		_has_prev = true
	if _grounded and not _flag("sliding") and _vy < -3.0:
		_land = 0.1
	_land = move_toward(_land, 0.0, delta * 0.45)


func _pose() -> Dictionary:
	var emote := _parent_emote()
	if emote != "":
		return _emote_pose(emote)
	if _flag("on_marks"):
		return _emote_pose(_mark_pose())
	var swing := sin(_cycle)
	var hang := _flag("hanging")
	var mantle := _flag("mantling")
	var slide := _flag("sliding")
	var wall := _wall()
	var idle := {
		"thigh_l": Vector3(0.05, 0, -0.04),
		"thigh_r": Vector3(0.05, 0, 0.04),
		"shin_l": Vector3(-0.12, 0, 0),
		"shin_r": Vector3(-0.12, 0, 0),
		"arm_l": Vector3(0.12, 0, -0.16),
		"arm_r": Vector3(0.12, 0, 0.16),
		"fore_l": Vector3(0.45, 0, 0),
		"fore_r": Vector3(0.45, 0, 0),
		"chest": Vector3(0.04 + sin(_clock * 1.7) * 0.025, 0, 0),
		"hips": Vector3.ZERO,
		"drop": -_land,
		"lean": 0.0,
	}
	if hang:
		var pull := 0.4 if mantle else 0.0
		return {
			"thigh_l": Vector3(0.35, 0, -0.05),
			"thigh_r": Vector3(0.35, 0, 0.05),
			"shin_l": Vector3(-1.05, 0, 0),
			"shin_r": Vector3(-1.05, 0, 0),
			"arm_l": Vector3(2.45, 0, 0.15),
			"arm_r": Vector3(2.45, 0, -0.15),
			"fore_l": Vector3(0.4, 0, 0),
			"fore_r": Vector3(0.4, 0, 0),
			"chest": Vector3(0.25 + pull, 0, 0),
			"hips": Vector3.ZERO,
			"drop": -0.05,
			"lean": 0.0,
		}
	if wall != 0:
		var side := float(wall)
		var scrape := sin(_cycle * 2.0)
		return {
			"thigh_l": Vector3(scrape * 0.55, 0, -0.08),
			"thigh_r": Vector3(-scrape * 0.55, 0, 0.08),
			"shin_l": Vector3(-0.35 - maxf(0.0, -scrape) * 0.5, 0, 0),
			"shin_r": Vector3(-0.35 - maxf(0.0, scrape) * 0.5, 0, 0),
			"arm_l": Vector3(0.2, 0, (-1.15 if side < 0.0 else 0.35)),
			"arm_r": Vector3(0.2, 0, (1.15 if side > 0.0 else -0.35)),
			"fore_l": Vector3((0.7 if side < 0.0 else 0.3), 0, 0),
			"fore_r": Vector3((0.7 if side > 0.0 else 0.3), 0, 0),
			"chest": Vector3(0.18, 0, side * 0.25),
			"hips": Vector3(0, scrape * 0.08, 0),
			"drop": 0.02,
			"lean": -side * 0.42,
		}
	if _fp and slide and not _grounded and _fp_camera_low():
		# Still in the slide crouch under a low roof. Pull the legs down
		# instead of tucking them up into the lens.
		return {
			"thigh_l": Vector3(0.2, 0, -0.06),
			"thigh_r": Vector3(0.16, 0, 0.06),
			"shin_l": Vector3(-0.35, 0, 0),
			"shin_r": Vector3(-0.3, 0, 0),
			"arm_l": Vector3(0.35, 0, -0.45),
			"arm_r": Vector3(0.3, 0, 0.4),
			"fore_l": Vector3(0.35, 0, 0),
			"fore_r": Vector3(0.3, 0, 0),
			"chest": Vector3(0.22, 0, 0),
			"hips": Vector3(0.08, 0, 0),
			"head": Vector3(-0.08, 0, 0),
			"drop": -0.5,
			"lean": 0.0,
		}
	if slide and _grounded:
		# Feet-first baseball slide. Legs stay nearly straight so the shoes lead.
		return {
			"thigh_l": Vector3(1.42, 0.06, -0.22),
			"thigh_r": Vector3(1.38, -0.06, 0.22),
			"shin_l": Vector3(-0.22, 0, 0),
			"shin_r": Vector3(-0.16, 0, 0),
			"arm_l": Vector3(0.55, 0.15, -1.15),
			"arm_r": Vector3(0.45, -0.1, 1.05),
			"fore_l": Vector3(0.15, 0, 0),
			"fore_r": Vector3(0.35, 0, 0),
			"chest": Vector3(0.42, 0, 0),
			"hips": Vector3(0.2, 0, 0),
			"head": Vector3(-0.15, 0, 0),
			"drop": -0.54,
			"lean": 0.04,
		}
	if not _grounded:
		var rising := _vy > 1.2
		var tuck := 0.95 if rising else 0.15
		return {
			"thigh_l": Vector3(tuck, 0, -0.06),
			"thigh_r": Vector3(tuck * 0.8, 0, 0.06),
			"shin_l": Vector3((-1.2 if rising else -0.2), 0, 0),
			"shin_r": Vector3((-1.05 if rising else -0.15), 0, 0),
			"arm_l": Vector3((-0.7 if rising else 0.35), 0, (-0.35 if rising else -0.7)),
			"arm_r": Vector3((-0.7 if rising else 0.35), 0, (0.35 if rising else 0.7)),
			"fore_l": Vector3((0.7 if rising else 0.25), 0, 0),
			"fore_r": Vector3((0.7 if rising else 0.25), 0, 0),
			"chest": Vector3((-0.12 if rising else 0.28), 0, 0),
			"hips": Vector3.ZERO,
			"head": Vector3((-0.2 if rising else 0.18), 0, 0),
			"drop": 0.0,
			"lean": 0.0,
		}
	if _speed > 1.4:
		var pace := clampf(_speed / 12.0, 0.0, 1.0)
		return {
			"thigh_l": Vector3(swing * 0.82, 0, -0.05),
			"thigh_r": Vector3(-swing * 0.82, 0, 0.05),
			"shin_l": Vector3(-0.15 + minf(0.0, swing) * 1.05, 0, 0),
			"shin_r": Vector3(-0.15 + minf(0.0, -swing) * 1.05, 0, 0),
			"arm_l": Vector3(-swing * 0.95, 0, -0.16),
			"arm_r": Vector3(swing * 0.95, 0, 0.16),
			"fore_l": Vector3(0.35 + absf(swing) * 0.3, 0, 0),
			"fore_r": Vector3(0.35 + absf(swing) * 0.3, 0, 0),
			"chest": Vector3(0.12 + pace * 0.16, -swing * 0.12, 0),
			"hips": Vector3(0, swing * 0.18, 0),
			"head": Vector3(-0.06, -swing * 0.06, 0),
			"drop": absf(swing) * 0.04 - _land,
			"lean": 0.0,
		}
	return idle


func _parent_emote() -> String:
	var parent := get_parent()
	if parent != null and "emote" in parent and str(parent.emote) != "":
		return str(parent.emote)
	return ""


func _emote_pose(id: String) -> Dictionary:
	var wave := sin(_clock * 8.0)
	var beat := sin(_clock * 6.5)
	var hop := absf(sin(_clock * 5.0))
	var pose := {
		"thigh_l": Vector3(0.05, 0, -0.04),
		"thigh_r": Vector3(0.05, 0, 0.04),
		"shin_l": Vector3(-0.12, 0, 0),
		"shin_r": Vector3(-0.12, 0, 0),
		"arm_l": Vector3(0.2, 0, -0.2),
		"arm_r": Vector3(0.2, 0, 0.2),
		"fore_l": Vector3(0.4, 0, 0),
		"fore_r": Vector3(0.4, 0, 0),
		"chest": Vector3(0.04, 0, 0),
		"hips": Vector3.ZERO,
		"head": Vector3.ZERO,
		"drop": 0.0,
		"lean": 0.0,
	}
	match id:
		"wave":
			pose["arm_r"] = Vector3(-2.55, 0.15, 0.35)
			pose["fore_r"] = Vector3(0.15 + wave * 0.85, 0, 0)
			pose["chest"] = Vector3(0.02, 0.18, 0)
			pose["hips"] = Vector3(0, 0.12, 0)
			pose["head"] = Vector3(-0.1, 0.35, 0.08)
			pose["lean"] = -0.06
		"cheer":
			pose["arm_l"] = Vector3(-2.7, 0, -0.45)
			pose["arm_r"] = Vector3(-2.7, 0, 0.45)
			pose["fore_l"] = Vector3(0.2 + hop * 0.35, 0, 0)
			pose["fore_r"] = Vector3(0.2 + hop * 0.35, 0, 0)
			pose["chest"] = Vector3(-0.22, 0, 0)
			pose["head"] = Vector3(-0.35, 0, 0)
			pose["thigh_l"] = Vector3(0.15 + hop * 0.2, 0, -0.05)
			pose["thigh_r"] = Vector3(0.15 + hop * 0.2, 0, 0.05)
			pose["drop"] = hop * 0.08
		"bow":
			var dip := clampf(sin(_clock * 1.6), 0.0, 1.0)
			pose["chest"] = Vector3(lerpf(0.15, 1.25, dip), 0, 0)
			pose["arm_l"] = Vector3(lerpf(0.3, 1.35, dip), 0, -0.15)
			pose["arm_r"] = Vector3(lerpf(0.3, 1.35, dip), 0, 0.15)
			pose["head"] = Vector3(lerpf(0.0, 0.45, dip), 0, 0)
			pose["drop"] = -0.14 * dip
		"flex":
			var pump := 0.85 + sin(_clock * 4.0) * 0.15
			pose["arm_l"] = Vector3(-1.35, 0, -1.25 * pump)
			pose["arm_r"] = Vector3(-1.35, 0, 1.25 * pump)
			pose["fore_l"] = Vector3(1.65, 0, 0)
			pose["fore_r"] = Vector3(1.65, 0, 0)
			pose["chest"] = Vector3(-0.18, 0, 0)
			pose["head"] = Vector3(-0.12, sin(_clock * 1.5) * 0.2, 0)
		"dance":
			pose["thigh_l"] = Vector3(0.55 + beat * 0.45, 0, -0.12)
			pose["thigh_r"] = Vector3(0.25 - beat * 0.45, 0, 0.12)
			pose["shin_l"] = Vector3(-0.35 - maxf(0.0, beat) * 0.6, 0, 0)
			pose["shin_r"] = Vector3(-0.35 - maxf(0.0, -beat) * 0.6, 0, 0)
			pose["arm_l"] = Vector3(-1.35 + beat * 0.55, 0, -0.55)
			pose["arm_r"] = Vector3(-0.25 - beat * 0.55, 0, 0.55)
			pose["fore_l"] = Vector3(0.8, 0, 0)
			pose["fore_r"] = Vector3(0.45, 0, 0)
			pose["hips"] = Vector3(0, beat * 0.55, 0)
			pose["chest"] = Vector3(0.05, -beat * 0.2, 0)
			pose["head"] = Vector3(0.05, beat * 0.25, 0)
			pose["drop"] = absf(beat) * 0.07
			pose["lean"] = beat * 0.08
		"sit":
			pose["thigh_l"] = Vector3(1.35, 0, -0.1)
			pose["thigh_r"] = Vector3(1.35, 0, 0.1)
			pose["shin_l"] = Vector3(-1.5, 0, 0)
			pose["shin_r"] = Vector3(-1.5, 0, 0)
			pose["arm_l"] = Vector3(0.85, 0, -0.28)
			pose["arm_r"] = Vector3(0.85, 0, 0.28)
			pose["fore_l"] = Vector3(1.15, 0, 0)
			pose["fore_r"] = Vector3(1.15, 0, 0)
			pose["chest"] = Vector3(0.22, 0, 0)
			pose["head"] = Vector3(0.12, sin(_clock * 1.2) * 0.08, 0)
			pose["drop"] = -0.46
		"spin":
			pose["arm_l"] = Vector3(-1.15, 0, -1.35)
			pose["arm_r"] = Vector3(-1.15, 0, 1.35)
			pose["fore_l"] = Vector3(0.15, 0, 0)
			pose["fore_r"] = Vector3(0.15, 0, 0)
			pose["head"] = Vector3(-0.15, 0, 0)
			pose["chest"] = Vector3(-0.05, 0, 0)
	return pose


func slide_posed() -> bool:
	if not _fp or _mascot_anim == null or not _mascot_anim.has_animation(_SLIDE_CLIP):
		return true
	if _mascot_anim.current_animation != _SLIDE_CLIP:
		return false
	return _mascot_anim.current_animation_position + 0.02 >= _SLIDE_LOOP_FROM


func has_mascot() -> bool:
	return _mascot != null and _spine != null


func set_first_person(on: bool) -> void:
	_fp = on
	_clear_fp_material()
	_restore_head()
	if on:
		_hide_skull_from_eyes()
	else:
		_clear_head_hide()
	if _head:
		_head.visible = true
	if arm_l:
		arm_l.visible = true
	if arm_r:
		arm_r.visible = true
	if _mascot:
		_mascot.visible = true
	if not on:
		_show_branch(hips)
		_show_branch(chest)


func _pose_fp_arms() -> void:
	# Keep the skull on the body. The eye camera skips it; every other camera sees it.
	_clear_fp_material()
	_restore_head()
	if _mascot:
		_mascot.visible = true
	_hide_skull_from_eyes()


func _measure_arms() -> void:
	if _arms_measured or _spine == null:
		return
	_arm_upper_l = _rest_span("mixamorig_LeftArm", "mixamorig_LeftForeArm")
	_arm_lower_l = _rest_span("mixamorig_LeftForeArm", "mixamorig_LeftHand")
	_arm_upper_r = _rest_span("mixamorig_RightArm", "mixamorig_RightForeArm")
	_arm_lower_r = _rest_span("mixamorig_RightForeArm", "mixamorig_RightHand")
	_arms_measured = _arm_upper_l > 0.01 and _arm_lower_l > 0.01 and _arm_upper_r > 0.01 and _arm_lower_r > 0.01


func _rest_span(from_name: String, to_name: String) -> float:
	var from_i := _spine.find_bone(from_name)
	var to_i := _spine.find_bone(to_name)
	if from_i < 0 or to_i < 0:
		return 0.0
	var from_p: Vector3 = _spine.get_bone_global_rest(from_i).origin
	var to_p: Vector3 = _spine.get_bone_global_rest(to_i).origin
	return from_p.distance_to(to_p)


func _hand_world(local: Vector3) -> Vector3:
	var parent := get_parent() as Node3D
	if parent == null:
		return global_position + local
	return parent.global_position + parent.global_transform.basis * local


func _reach(local_l: Vector3, local_r: Vector3) -> void:
	if _spine == null:
		return
	_measure_arms()
	if not _arms_measured:
		return
	_solve_arm("mixamorig_LeftArm", "mixamorig_LeftForeArm", "mixamorig_LeftHand", _hand_world(local_l), Vector3(-0.55, 0.2, 0.1), _arm_upper_l, _arm_lower_l)
	_solve_arm("mixamorig_RightArm", "mixamorig_RightForeArm", "mixamorig_RightHand", _hand_world(local_r), Vector3(0.55, 0.2, 0.1), _arm_upper_r, _arm_lower_r)


func _flinch() -> void:
	if _spine == null:
		return
	var bone := _spine.find_bone("mixamorig_Spine")
	if bone < 0:
		return
	var pose := _spine.get_bone_rest(bone)
	pose.basis = pose.basis * Basis(Vector3.RIGHT, 0.42)
	_spine.set_bone_pose(bone, pose)


func _solve_arm(upper_name: String, fore_name: String, hand_name: String, target_world: Vector3, pole_world: Vector3, upper_len: float, lower_len: float) -> void:
	var upper := _spine.find_bone(upper_name)
	var fore := _spine.find_bone(fore_name)
	var hand := _spine.find_bone(hand_name)
	if upper < 0 or fore < 0 or hand < 0:
		return
	var shoulder: Vector3 = _spine.get_bone_global_pose(upper).origin
	var target: Vector3 = _spine.to_local(target_world)
	var to := target - shoulder
	var reach := to.length()
	if reach < 0.001:
		return
	var max_r := upper_len + lower_len - 0.001
	var min_r := absf(upper_len - lower_len) + 0.001
	var dist := clampf(reach, min_r, max_r)
	var to_n := to / reach
	var cos_a := clampf((upper_len * upper_len + dist * dist - lower_len * lower_len) / (2.0 * upper_len * dist), -1.0, 1.0)
	var sin_a := sqrt(maxf(0.0, 1.0 - cos_a * cos_a))
	var pole: Vector3 = _spine.to_local(_spine.to_global(shoulder) + pole_world) - shoulder
	pole = pole - to_n * pole.dot(to_n)
	if pole.length() < 0.001:
		pole = Vector3.UP.cross(to_n)
	pole = pole.normalized()
	var elbow := shoulder + to_n * (cos_a * upper_len) + pole * (sin_a * upper_len)
	_aim_bone(upper, elbow - shoulder)
	_spine.force_update_all_bone_transforms()
	var wrist_goal := shoulder + to_n * dist
	_aim_bone(fore, wrist_goal - elbow)
	_spine.force_update_all_bone_transforms()
	_carry_hand(hand, fore)


func _aim_bone(bone: int, along: Vector3) -> void:
	if along.length() < 0.001:
		return
	var rest := _spine.get_bone_global_rest(bone)
	var rest_y: Vector3 = rest.basis * Vector3.UP
	if rest_y.length() < 0.001:
		return
	var arc := Quaternion(rest_y.normalized(), along.normalized())
	var desired := Basis(arc) * rest.basis
	var parent := _spine.get_bone_parent(bone)
	var local := desired
	if parent >= 0:
		local = _spine.get_bone_global_pose(parent).basis.inverse() * desired
	var pose := _spine.get_bone_pose(bone)
	pose.basis = local.orthonormalized()
	_spine.set_bone_pose(bone, pose)


func _carry_hand(hand: int, fore: int) -> void:
	var rest_hand := _spine.get_bone_global_rest(hand).basis
	var rest_fore := _spine.get_bone_global_rest(fore).basis
	var new_fore := _spine.get_bone_global_pose(fore).basis
	var desired := new_fore * rest_fore.inverse() * rest_hand
	var parent := _spine.get_bone_parent(hand)
	var local := desired
	if parent >= 0:
		local = _spine.get_bone_global_pose(parent).basis.inverse() * desired
	var pose := _spine.get_bone_pose(hand)
	pose.basis = local.orthonormalized()
	_spine.set_bone_pose(hand, pose)


func _camera_low() -> bool:
	var parent := get_parent()
	if parent == null or not ("camera" in parent):
		return false
	var cam: Camera3D = parent.get("camera")
	if cam == null:
		return false
	return to_local(cam.global_position).y < 0.9


func _hide_skull_from_eyes() -> void:
	var mesh := _char_mesh()
	if mesh == null or _spine == null:
		return
	var head := _spine.find_bone("mixamorig_Head")
	if head < 0:
		return
	_ensure_head_hide(mesh)
	if _head_mat == null:
		return
	var pose := _spine.get_bone_global_pose(head)
	var up := _spine.global_transform.basis.y
	if up.length() < 0.001:
		up = Vector3.UP
	up = up.normalized()
	var bone_at: Vector3 = _spine.to_global(pose.origin)
	_head_mat.set_shader_parameter("head_bone", bone_at)
	_head_mat.set_shader_parameter("head_pos", bone_at + up * 0.16)
	var neck := _spine.find_bone("mixamorig_Neck")
	var neck_at := bone_at - up * 0.1
	if neck >= 0:
		neck_at = _spine.to_global(_spine.get_bone_global_pose(neck).origin)
	_head_mat.set_shader_parameter("neck_pos", neck_at)


func _ensure_head_hide(mesh: MeshInstance3D) -> void:
	if _head_mat == null:
		var shader := load("res://shaders/fp_head.gdshader") as Shader
		_head_mat = ShaderMaterial.new()
		_head_mat.shader = shader
		var active := mesh.get_active_material(0)
		if active is StandardMaterial3D:
			var skin := active as StandardMaterial3D
			if skin.albedo_texture:
				_head_mat.set_shader_parameter("albedo_tex", skin.albedo_texture)
			_head_mat.set_shader_parameter("albedo_color", skin.albedo_color)
			_head_mat.set_shader_parameter("roughness_amount", skin.roughness)
			_head_mat.set_shader_parameter("metallic_amount", skin.metallic)
			if skin.emission_enabled:
				_head_mat.set_shader_parameter("emission_color", Vector3(skin.emission.r, skin.emission.g, skin.emission.b))
				_head_mat.set_shader_parameter("emission_energy", skin.emission_energy_multiplier)
				if skin.emission_texture:
					_head_mat.set_shader_parameter("emission_tex", skin.emission_texture)
	mesh.material_override = _head_mat


func _clear_head_hide() -> void:
	var mesh := _char_mesh()
	if mesh and mesh.material_override == _head_mat:
		mesh.material_override = null


func _restore_head() -> void:
	if _spine == null:
		return
	for bone_name in ["mixamorig_Head", "mixamorig_Neck"]:
		var bone := _spine.find_bone(bone_name)
		if bone >= 0:
			_spine.set_bone_pose_scale(bone, Vector3.ONE)


func _char_mesh() -> MeshInstance3D:
	if _mascot == null:
		return null
	return _mascot.find_child("char1", true, false) as MeshInstance3D


func _ensure_fp_material() -> void:
	var mesh := _char_mesh()
	if mesh == null:
		return
	if _fp_mat == null:
		var shader := load("res://shaders/fp_arms.gdshader") as Shader
		_fp_mat = ShaderMaterial.new()
		_fp_mat.shader = shader
		var active := mesh.get_active_material(0)
		if active is StandardMaterial3D:
			var skin := active as StandardMaterial3D
			if skin.albedo_texture:
				_fp_mat.set_shader_parameter("albedo_tex", skin.albedo_texture)
			_fp_mat.set_shader_parameter("albedo_color", skin.albedo_color)
	mesh.material_override = _fp_mat


func _clear_fp_material() -> void:
	var mesh := _char_mesh()
	if mesh and mesh.material_override == _fp_mat:
		mesh.material_override = null


func _paint_fp_arms() -> void:
	if _fp_mat == null:
		return
	var l_fore := _bone_world("mixamorig_LeftForeArm")
	var l_hand := _bone_world("mixamorig_LeftHand")
	var r_fore := _bone_world("mixamorig_RightForeArm")
	var r_hand := _bone_world("mixamorig_RightHand")
	var l_out := l_hand - l_fore
	var r_out := r_hand - r_fore
	var l_dir := l_out.normalized() if l_out.length() > 0.001 else Vector3.FORWARD
	var r_dir := r_out.normalized() if r_out.length() > 0.001 else Vector3.FORWARD
	var l_tip := l_hand + l_dir * 0.2
	var r_tip := r_hand + r_dir * 0.2
	_fp_mat.set_shader_parameter("arm_radius", 0.16)
	_fp_mat.set_shader_parameter("hide_near", 0.2)
	_fp_mat.set_shader_parameter("a0", l_fore)
	_fp_mat.set_shader_parameter("a1", l_tip)
	_fp_mat.set_shader_parameter("b0", l_fore)
	_fp_mat.set_shader_parameter("b1", l_tip)
	_fp_mat.set_shader_parameter("c0", r_fore)
	_fp_mat.set_shader_parameter("c1", r_tip)
	_fp_mat.set_shader_parameter("d0", r_fore)
	_fp_mat.set_shader_parameter("d1", r_tip)


func _bone_world(bone_name: String) -> Vector3:
	var bone := _spine.find_bone(bone_name)
	if bone < 0:
		return global_position
	return _spine.to_global(_spine.get_bone_global_pose(bone).origin)


func _cull_near_camera() -> void:
	var parent := get_parent()
	if parent == null or not ("camera" in parent):
		return
	var cam: Camera3D = parent.camera
	if cam == null:
		return
	var origin := cam.global_position
	_cull_branch(hips, origin)
	_cull_branch(chest, origin)


func _cull_branch(node: Node, origin: Vector3) -> void:
	if node == null:
		return
	for child in node.get_children():
		if child == _head or child == arm_l or child == arm_r:
			continue
		if child is MeshInstance3D:
			var mesh := child as MeshInstance3D
			mesh.visible = origin.distance_to(mesh.global_position) > 0.28
		_cull_branch(child, origin)


func _show_branch(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = true
		_show_branch(child)


func _flag(prop: String) -> bool:
	var parent := get_parent()
	if parent == null or not (prop in parent):
		return false
	return bool(parent.get(prop))


func _fp_camera_low() -> bool:
	var parent := get_parent()
	if parent == null or not ("head" in parent):
		return false
	var head: Node3D = parent.get("head")
	return head != null and head.position.y < 0.9


func _wall() -> int:
	var parent := get_parent()
	if parent == null or not ("wall_side" in parent):
		return 0
	return int(parent.get("wall_side"))


func _blend(node: Node3D, target: Vector3, weight: float) -> void:
	if node == null:
		return
	node.rotation.x = lerp_angle(node.rotation.x, target.x, weight)
	node.rotation.y = lerp_angle(node.rotation.y, target.y, weight)
	node.rotation.z = lerp_angle(node.rotation.z, target.z, weight)


func _pivot(parent: Node3D, pos: Vector3) -> Node3D:
	var node := Node3D.new()
	node.position = pos
	parent.add_child(node)
	return node


func _box(parent: Node3D, pos: Vector3, size: Vector3, joint: bool) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.position = pos
	parent.add_child(mesh_node)
	if joint:
		_joints.append(mesh_node)
	else:
		_body.append(mesh_node)
	return mesh_node


func _ear(parent: Node3D, side: int) -> void:
	var mesh_node := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(0.09, 0.16, 0.05)
	mesh_node.mesh = prism
	mesh_node.position = Vector3(float(side) * 0.09, 0.18, 0.0)
	mesh_node.rotation.z = float(side) * -0.35
	parent.add_child(mesh_node)
	_body.append(mesh_node)


func _eye(parent: Node3D, side: int) -> void:
	var mesh_node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.045, 0.055, 0.03)
	mesh_node.mesh = box
	mesh_node.position = Vector3(float(side) * 0.055, 0.02, -0.15)
	mesh_node.material_override = _mat(Color("141210"), 0.3)
	parent.add_child(mesh_node)
	_fixed.append(mesh_node)


func set_style(id: String) -> void:
	var next := id if not Styles.get_style(id).is_empty() else "bulbous"
	var changed := next != style_id
	style_id = next
	# The card calls this before the rig exists. Attaching here and again in
	# _ready left a second body behind the first runner.
	if _pelvis == null:
		return
	_apply_style()
	if changed or _mascot == null:
		_swap_mascot()


func _apply_style() -> void:
	var round := false
	var pelvis_s := Vector3(0.38, 0.14, 0.2)
	var chest_s := Vector3(0.34, 0.46, 0.2)
	var chest_p := Vector3(0, 0.24, 0)
	var collar_s := Vector3(0.58, 0.1, 0.16)
	var neck_s := Vector3(0.1, 0.1, 0.1)
	var head_r := 0.15
	var head_h := 0.3
	var thigh_s := Vector3(0.13, 0.42, 0.15)
	var shin_s := Vector3(0.12, 0.36, 0.14)
	var shoe_s := Vector3(0.13, 0.08, 0.28)
	var arm_s := Vector3(0.1, 0.3, 0.1)
	var fore_s := Vector3(0.09, 0.26, 0.09)
	var hand_s := Vector3(0.08, 0.07, 0.1)
	match style_id:
		"round":
			round = true
			pelvis_s = Vector3(0.44, 0.3, 0.34)
			chest_s = Vector3(0.48, 0.44, 0.42)
			chest_p = Vector3(0, 0.3, 0)
			collar_s = Vector3(0.22, 0.12, 0.2)
			neck_s = Vector3(0.14, 0.1, 0.14)
			head_r = 0.2
			head_h = 0.4
			thigh_s = Vector3(0.18, 0.3, 0.18)
			shin_s = Vector3(0.15, 0.26, 0.15)
			shoe_s = Vector3(0.16, 0.1, 0.2)
			arm_s = Vector3(0.14, 0.22, 0.14)
			fore_s = Vector3(0.12, 0.18, 0.12)
			hand_s = Vector3(0.11, 0.09, 0.11)
		"slick":
			pelvis_s = Vector3(0.26, 0.1, 0.14)
			chest_s = Vector3(0.22, 0.56, 0.13)
			chest_p = Vector3(0, 0.3, 0)
			collar_s = Vector3(0.38, 0.05, 0.11)
			neck_s = Vector3(0.06, 0.14, 0.06)
			head_r = 0.11
			head_h = 0.24
			thigh_s = Vector3(0.08, 0.48, 0.09)
			shin_s = Vector3(0.07, 0.42, 0.08)
			shoe_s = Vector3(0.08, 0.045, 0.34)
			arm_s = Vector3(0.065, 0.34, 0.065)
			fore_s = Vector3(0.055, 0.3, 0.055)
			hand_s = Vector3(0.055, 0.045, 0.08)
		"fat":
			pelvis_s = Vector3(0.56, 0.24, 0.36)
			chest_s = Vector3(0.62, 0.42, 0.4)
			chest_p = Vector3(0, 0.2, 0.03)
			collar_s = Vector3(0.74, 0.12, 0.3)
			neck_s = Vector3(0.18, 0.08, 0.18)
			head_r = 0.19
			head_h = 0.34
			thigh_s = Vector3(0.22, 0.34, 0.24)
			shin_s = Vector3(0.18, 0.28, 0.2)
			shoe_s = Vector3(0.2, 0.1, 0.26)
			arm_s = Vector3(0.17, 0.24, 0.17)
			fore_s = Vector3(0.15, 0.2, 0.15)
			hand_s = Vector3(0.13, 0.1, 0.12)
		"cat":
			round = true
			pelvis_s = Vector3(0.32, 0.18, 0.24)
			chest_s = Vector3(0.34, 0.32, 0.28)
			chest_p = Vector3(0, 0.22, 0)
			collar_s = Vector3(0.2, 0.08, 0.16)
			neck_s = Vector3(0.08, 0.08, 0.08)
			head_r = 0.18
			head_h = 0.3
			thigh_s = Vector3(0.1, 0.28, 0.12)
			shin_s = Vector3(0.08, 0.24, 0.1)
			shoe_s = Vector3(0.12, 0.06, 0.16)
			arm_s = Vector3(0.08, 0.2, 0.08)
			fore_s = Vector3(0.07, 0.16, 0.07)
			hand_s = Vector3(0.08, 0.06, 0.08)
	_fit(_pelvis, Vector3(0, 0.82, 0), pelvis_s, round)
	_fit(_torso, chest_p, chest_s, round)
	_fit(_collar, Vector3(0, 0.5, 0), collar_s, round)
	_fit(_neck, Vector3(0, 0.62, 0), neck_s, round)
	_fit(_thigh_l, Vector3(0, -0.21, 0), thigh_s, round)
	_fit(_thigh_r, Vector3(0, -0.21, 0), thigh_s, round)
	_fit(_shin_l, Vector3(0, -0.18, 0), shin_s, round)
	_fit(_shin_r, Vector3(0, -0.18, 0), shin_s, round)
	_fit(_shoe_l, Vector3(0, -0.38, -0.07), shoe_s, round)
	_fit(_shoe_r, Vector3(0, -0.38, -0.07), shoe_s, round)
	_fit(_arm_l, Vector3(0, -0.15, 0), arm_s, round)
	_fit(_arm_r, Vector3(0, -0.15, 0), arm_s, round)
	_fit(_fore_l, Vector3(0, -0.13, 0), fore_s, round)
	_fit(_fore_r, Vector3(0, -0.13, 0), fore_s, round)
	_fit(_hand_l, Vector3(0, -0.28, -0.02), hand_s, round)
	_fit(_hand_r, Vector3(0, -0.28, -0.02), hand_s, round)
	if _skull:
		var sphere := SphereMesh.new()
		sphere.radius = head_r
		sphere.height = head_h
		_skull.mesh = sphere
	var cat := style_id == "cat"
	if _visor:
		_visor.visible = not cat
	if _ears:
		_ears.visible = cat
	if _eyes:
		_eyes.visible = cat
	if _tail:
		_tail.visible = cat


func _fit(node: MeshInstance3D, pos: Vector3, size: Vector3, round: bool) -> void:
	if node == null:
		return
	node.position = pos
	if round:
		var sphere := SphereMesh.new()
		var rad := maxf(size.x, size.z) * 0.5
		sphere.radius = rad
		sphere.height = maxf(size.y, rad * 2.0)
		node.mesh = sphere
	else:
		var box := BoxMesh.new()
		box.size = size
		node.mesh = box


func set_hat(_id: String) -> void:
	_clear_hat()


func set_trail(id: String) -> void:
	trail_id = id if id != "" else "off"
	if _trail != null and _trail.has_method("set_trail"):
		_trail.preview_pose = trail_preview
		_trail.set_trail(trail_id)


func _rebuild_hat() -> void:
	_clear_hat()


func _clear_hat() -> void:
	for mesh in _hat_meshes:
		_body.erase(mesh)
		_joints.erase(mesh)
		_fixed.erase(mesh)
	_hat_meshes.clear()
	if _hat_root != null:
		_hat_root.queue_free()
		_hat_root = null


func _make_hat(id: String) -> void:
	match id:
		"beanie":
			_hat_sphere(Vector3(0, 0.2, 0), 0.17, 0.26, Vector3(1, 0.72, 1), "cloth")
		"band":
			_hat_box(Vector3(0, 0.05, -0.145), Vector3(0.28, 0.05, 0.04), "cloth")
			_hat_box(Vector3(0, 0.05, 0.145), Vector3(0.22, 0.05, 0.035), "cloth")
			_hat_box(Vector3(-0.155, 0.05, 0), Vector3(0.035, 0.05, 0.26), "cloth")
			_hat_box(Vector3(0.155, 0.05, 0), Vector3(0.035, 0.05, 0.26), "cloth")
		"bucket":
			_hat_box(Vector3(0, 0.2, 0), Vector3(0.26, 0.12, 0.26), "cloth")
			_hat_box(Vector3(0, 0.14, 0), Vector3(0.46, 0.025, 0.46), "trim")
		"beret":
			_hat_disc(Vector3(0.04, 0.2, -0.02), 0.2, 0.16, 0.055, Vector3(0.35, 0, 0.45), "cloth")
		"hardhat":
			_hat_box(Vector3(0, 0.22, 0), Vector3(0.32, 0.14, 0.34), "cloth")
			_hat_box(Vector3(0, 0.15, 0), Vector3(0.44, 0.028, 0.46), "trim")
			_hat_box(Vector3(0, 0.28, 0), Vector3(0.16, 0.03, 0.18), "trim")
		"visor":
			_hat_box(Vector3(0, 0.07, -0.12), Vector3(0.3, 0.04, 0.06), "cloth")
			var brim := _hat_box(Vector3(0, 0.055, -0.22), Vector3(0.3, 0.02, 0.16), "trim")
			brim.rotation.x = 0.22
		"boater":
			_hat_disc(Vector3(0, 0.22, 0), 0.13, 0.13, 0.12, Vector3.ZERO, "cloth")
			_hat_disc(Vector3(0, 0.16, 0), 0.24, 0.24, 0.025, Vector3.ZERO, "trim")
			_hat_box(Vector3(0, 0.2, 0), Vector3(0.27, 0.035, 0.02), "trim")
		"hood":
			_hat_box(Vector3(0, 0.16, 0.06), Vector3(0.36, 0.3, 0.22), "cloth")
			_hat_box(Vector3(0, 0.08, -0.02), Vector3(0.3, 0.06, 0.08), "trim")
		"tophat":
			_hat_disc(Vector3(0, 0.34, 0), 0.12, 0.13, 0.28, Vector3.ZERO, "cloth")
			_hat_disc(Vector3(0, 0.18, 0), 0.24, 0.24, 0.028, Vector3.ZERO, "trim")
			_hat_box(Vector3(0, 0.26, -0.125), Vector3(0.26, 0.04, 0.02), "trim")
		"crown":
			_hat_box(Vector3(0, 0.16, 0), Vector3(0.3, 0.045, 0.3), "prize")
			for i in 5:
				var ang := float(i) / 5.0 * TAU
				var p := Vector3(sin(ang) * 0.12, 0.24, cos(ang) * 0.12)
				_hat_box(p, Vector3(0.045, 0.1, 0.045), "prize")
		_:
			_hat_box(Vector3(0, 0.2, -0.01), Vector3(0.24, 0.11, 0.26), "cloth")
			var brim := _hat_box(Vector3(0, 0.145, -0.18), Vector3(0.24, 0.022, 0.14), "trim")
			brim.rotation.x = 0.2
			_hat_box(Vector3(0, 0.16, -0.12), Vector3(0.24, 0.035, 0.02), "trim")


func _hat_box(pos: Vector3, size: Vector3, kind: String) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.position = pos
	_hat_root.add_child(mesh_node)
	_keep_hat(mesh_node, kind)
	return mesh_node


func _hat_sphere(pos: Vector3, radius: float, height: float, squash: Vector3, kind: String) -> void:
	var mesh_node := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = height
	mesh_node.mesh = sphere
	mesh_node.position = pos
	mesh_node.scale = squash
	_hat_root.add_child(mesh_node)
	_keep_hat(mesh_node, kind)


func _hat_disc(pos: Vector3, top_r: float, bot_r: float, height: float, rot: Vector3, kind: String) -> void:
	var mesh_node := MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = top_r
	disc.bottom_radius = bot_r
	disc.height = height
	mesh_node.mesh = disc
	mesh_node.position = pos
	mesh_node.rotation = rot
	_hat_root.add_child(mesh_node)
	_keep_hat(mesh_node, kind)


func _keep_hat(mesh_node: MeshInstance3D, kind: String) -> void:
	_hat_meshes.append(mesh_node)
	if kind == "trim":
		_joints.append(mesh_node)
	elif kind == "prize":
		mesh_node.material_override = _mat(Color("e2b84a"), 0.35)
		_fixed.append(mesh_node)
	else:
		_body.append(mesh_node)


func set_ghost(alpha: float) -> void:
	_ghost_alpha = alpha
	if rig == null:
		return
	_ghost_branch(self, alpha)
	if name_tag:
		name_tag.modulate = Color(0.98, 0.96, 0.92)
		name_tag.outline_modulate = tint.darkened(0.25)


func _ghost_branch(node: Node, alpha: float) -> void:
	if node == _mascot:
		_ghost_mascot(alpha)
		return
	for child in node.get_children():
		if child is MeshInstance3D:
			var mesh := child as MeshInstance3D
			var base := tint
			if mesh.material_override is StandardMaterial3D:
				base = (mesh.material_override as StandardMaterial3D).albedo_color
			mesh.material_override = _ghost_mat(base, alpha)
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_ghost_branch(child, alpha)


func _ghost_mascot(alpha: float) -> void:
	var mesh := _mascot.find_child("char1", true, false) as MeshInstance3D
	if mesh == null:
		return
	var active := mesh.get_active_material(0)
	if active == null:
		return
	var ghost := active.duplicate() as StandardMaterial3D
	if ghost == null:
		return
	ghost.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost.albedo_color.a = alpha
	mesh.material_override = ghost
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _mat(color: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat


func _ghost_mat(color: Color, alpha: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat.albedo_color = Color(color.r, color.g, color.b, alpha)
	mat.roughness = 0.45
	mat.disable_receive_shadows = true
	mat.emission_enabled = true
	mat.emission = Color(color.r, color.g, color.b)
	mat.emission_energy_multiplier = 0.45
	return mat
