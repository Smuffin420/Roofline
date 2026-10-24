extends CharacterBody3D

const RUN_SPEED := 9.2
const SLIDE_SPEED := 12.6
const SLIDE_CRAWL := 3.6
const GROUND_ACCEL := 55.0
const AIR_ACCEL := 14.0
const GRAVITY := 28.0
const JUMP_V := 7.7
const WALL_JUMP_V := 13.6
const FALL_DEPTH := 16.0
const WALL_KICK := 7.6
const STAND_H := 1.72
const SLIDE_H := 0.9
const RADIUS := 0.32
const MannequinScript := preload("res://scripts/mannequin.gd")
const Emotes := preload("res://scripts/emotes.gd")
const Items := preload("res://scripts/items.gd")
const BrickScript := preload("res://scripts/brick.gd")
const SlickScript := preload("res://scripts/slick.gd")

var yaw := 0.0
var pitch := 0.0
var sliding := false
var slide_time := 0.0
var wall_running := false
var wall_side := 0
var wall_normal := Vector3.ZERO
var wall_time := 0.0
var ban_normal := Vector3.ZERO
var ban_time := 0.0
var coyote := 0.0
var jump_buffer := 0.0
var air_time := 0.0
var checkpoint_index := 0
var checkpoint_pos := Vector3.ZERO
var run_cycle := 0.0
var land_dip := 0.0
var fov_kick := 0.0
var stunned := 0.0
var finished := false
var eliminated := false
var won := false
var glide_left := 0.0
var cinematic := false
var on_marks := false
var _finish_view := false
var race_time := 0.0
var message := ""
var message_time := 0.0
var player_color := Color("e23b2f")
var worn_hat := "cap"
var worn_style := "bulbous"
var worn_trail := "off"
var display_name := "P1"
var is_bot := false
var rival := false
var view_player := false
var third_person := false
var _cam_hold := Vector3.ZERO
var _cam_held := false
var lane_bias := 0.0
var spawn_slot := 0
var finish_reported := false
var _cheer_queued := false
var _cheered := false
var falls := 0
var shove_lock := 0.0
var bump_lock := 0.0
var touch_lock := 0.0
var nudge_lock := 0.0
var boost_lock := 0.0
var boost_time := 0.0
var boost_back := false
var boost_speed := 22.0
var ice_hold := 0.0
var slick_speed := 0.0
var _bot_saw_floor := false
var _bot_set := false
var bot_style := 0.5
var bot_skill := 0.8
var bot_speed := 8.5
var bot_lane_x := 0.0
var bot_lane_time := 0.0
var bot_jump_wait := 0.0
var bot_gap_set := false
var bot_gap_late := false
var _bot_rng := RandomNumberGenerator.new()
var suppress_jump := false
var _step_wait := 0.0
var hanging := false
var mantling := false
var hang_time := 0.0
var mantle_time := 0.0
var grab_lock := 0.0
var hang_normal := Vector3.ZERO
var hang_pos := Vector3.ZERO
var mantle_from := Vector3.ZERO
var mantle_to := Vector3.ZERO
var lift := 0.0
var _drift := Vector3.ZERO
var pop_lock := 0.0
var emote := ""
var emote_time := 0.0
var bot_stall := 0.0
var bot_mark_z := 0.0
var bot_marked := false
var held_item := ""
var balloons := 0
var guard_up := false
var mercy := 0.0
var dash_time := 0.0
var dash_dir := Vector3.ZERO
var zipping := false
var zip_from := Vector3.ZERO
var zip_to := Vector3.ZERO
var zip_along := 0.0
var battle_wait := 0.0
var battle_spot := Vector3.ZERO
var battle_stuck := 0.0
var battle_anchor := Vector3.ZERO
var battle_jump := false
var _balloon_meshes: Array[MeshInstance3D] = []
var _guard_mesh: MeshInstance3D
var _item_mesh: MeshInstance3D
var _shown_item := ""

var net_pos := Vector3.ZERO
var net_yaw := 0.0
var net_pitch := 0.0
var has_net := false

var shape: CapsuleShape3D
var collision: CollisionShape3D
var head: Node3D
var camera: Camera3D
var left_hand: Node3D
var right_hand: Node3D
var mannequin: Node3D
var forearm_l: MeshInstance3D
var forearm_r: MeshInstance3D
var ray_l: RayCast3D
var ray_r: RayCast3D
var ceil_ray: RayCast3D
var ahead_ray: RayCast3D
var sense_l: RayCast3D
var sense_r: RayCast3D
var duct_ray: RayCast3D
var pit_ray: RayCast3D
var block_ray: RayCast3D
var rise_ray: RayCast3D
var grab_ray: RayCast3D


func _ready() -> void:
	add_to_group("runners")
	_build_body()
	ensure_actions()
	collision_layer = 2
	# Layer 1 is the course. Layer 2 is every runner, including bots. The speedrun ghost is not a body.
	collision_mask = 1 | 2
	floor_snap_length = 0.55
	floor_max_angle = deg_to_rad(56)
	up_direction = Vector3.UP
	if checkpoint_pos == Vector3.ZERO:
		checkpoint_pos = global_position
	if view_player:
		camera.current = true
		third_person = Profile.use_third()
		_apply_view()
	else:
		camera.current = false
		left_hand.visible = false
		right_hand.visible = false
	_apply_color()
	_build_battle_gear()


func is_local() -> bool:
	if multiplayer.multiplayer_peer == null:
		return true
	return is_multiplayer_authority()


func _sfx(id: String, volume_db: float = 0.0, pitch: float = 1.0, cutoff: float = -1.0, shared: bool = false) -> void:
	if view_player:
		Sfx.play(id, volume_db, pitch, cutoff)
	else:
		_crowd_sound(id, shared)
	if not shared or not is_local() or multiplayer.multiplayer_peer == null:
		return
	if id == "hit" or id == "boost":
		_hear.rpc(id, volume_db, pitch, cutoff)


func _crowd_sound(id: String, shared: bool) -> void:
	if id == "hit":
		Sfx.play("hit", -9.0, 1.0, 0.16)
	elif shared and id == "boost":
		Sfx.play("boost", -16.0, 1.55, 0.07)


@rpc("any_peer", "unreliable")
func _hear(id: String, _volume_db: float, _pitch: float, _cutoff: float) -> void:
	if multiplayer.get_remote_sender_id() == 0:
		return
	_crowd_sound(id, true)


func _exit_tree() -> void:
	if view_player:
		Sfx.slide(false, 0.0)


func _play_steps(delta: float) -> void:
	if not view_player or is_bot:
		return
	Sfx.slide(sliding and is_on_floor(), horizontal_speed())
	if sliding and is_on_floor():
		return
	var moving := horizontal_speed() > 2.2 and (is_on_floor() or wall_running)
	if not moving:
		_step_wait = 0.0
		return
	var gap := clampf(2.5 / maxf(horizontal_speed(), 3.0), 0.22, 0.46)
	_step_wait += delta
	if _step_wait < gap:
		return
	_step_wait = 0.0
	if _on_ice():
		Sfx.play("snow", -8.0)
	elif wall_running:
		Sfx.play("step", -12.0, 1.12)
	else:
		Sfx.play("step", -7.0)


func horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func format_time() -> String:
	var m := int(race_time) / 60
	var s := race_time - float(m * 60)
	return "%d:%05.2f" % [m, s]


func reach_checkpoint(index: int, pos: Vector3) -> void:
	if not is_local() or index <= checkpoint_index:
		return
	checkpoint_index = index
	checkpoint_pos = pos
	if view_player:
		Sfx.play("check", -4.0)


func eliminate() -> void:
	if finished or eliminated:
		return
	eliminated = true
	zipping = false
	sliding = false
	if hanging:
		_clear_hang()
	_leave_wall()
	velocity.x = 0.0
	velocity.z = 0.0
	message = "Eliminated"
	message_time = 8.0
	if mannequin != null and mannequin.has_method("show_eliminated"):
		mannequin.show_eliminated()


func queue_cheer() -> void:
	_cheer_queued = true


func reach_finish() -> void:
	if not is_local() or finished or eliminated:
		return
	finished = true
	# Count the pass here. The body keeps running so it clears the posts.
	glide_left = 4.0
	_drop_body_block()
	message = "Finished  %s" % format_time()
	message_time = 99.0
	if view_player:
		Sfx.play("finish", -2.0)
	_report_finish()


func _drop_body_block() -> void:
	# Stay on the roof, but other runners can pass through.
	collision_layer = 0
	collision_mask = 1


func _glide_finish(delta: float) -> void:
	_leave_wall()
	sliding = false
	rotation.y = lerp_angle(rotation.y, 0.0, 1.0 - exp(-10.0 * delta))
	yaw = rotation.y
	velocity.x = move_toward(velocity.x, 0.0, 24.0 * delta)
	velocity.z = -9.0
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	glide_left -= 9.0 * delta
	if glide_left <= 0.0:
		glide_left = 0.0
		velocity.x = 0.0
		velocity.z = 0.0
		_open_finish_view()


func _open_finish_view() -> void:
	if _finish_view or not view_player:
		return
	_finish_view = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if mannequin:
		mannequin.visible = true
		mannequin.set_first_person(false)
	if left_hand:
		left_hand.visible = false
	if right_hand:
		right_hand.visible = false


func celebrate() -> void:
	if not is_bot or finished == false:
		return
	var picks: Array[String] = ["wave", "cheer", "dance"]
	emote = picks[_bot_rng.randi() % picks.size()]
	emote_time = 8.0


func play_emote(id: String) -> void:
	if not finished or not is_local():
		return
	if not Emotes.is_open(id, Profile.reward_level()):
		return
	emote = id
	emote_time = 3.4 if id == "dance" else 2.6
	message = id.capitalize()
	message_time = 0.7


func blow_up() -> void:
	if finished:
		return
	lift = 0.1


func _report_finish() -> void:
	if finish_reported:
		return
	finish_reported = true
	var race := get_tree().get_first_node_in_group("race")
	if race != null and race.has_method("runner_finished"):
		race.runner_finished(self)


static func ensure_actions() -> void:
	var move_dead := 0.22
	if Settings != null:
		move_dead = Settings.move_deadzone()
	var names: Array[String] = ["move_forward", "move_back", "move_left", "move_right", "jump", "slide", "pause", "restart", "view", "item"]
	for action in names:
		var dead := move_dead if action.begins_with("move_") else 0.5
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			InputMap.action_set_deadzone(action, dead)
		else:
			InputMap.add_action(action, dead)
	_add_action("move_forward", move_dead)
	_add_action("move_back", move_dead)
	_add_action("move_left", move_dead)
	_add_action("move_right", move_dead)
	_add_action("jump", 0.5)
	_add_action("slide", 0.5)
	_add_action("pause", 0.5)
	_add_action("restart", 0.5)
	_bind_key("move_forward", KEY_W)
	_bind_key("move_back", KEY_S)
	_bind_key("move_left", KEY_A)
	_bind_key("move_right", KEY_D)
	_bind_key("jump", KEY_SPACE)
	_bind_key("slide", KEY_SHIFT)
	_bind_key("slide", KEY_C)
	_bind_key("restart", KEY_R)
	_add_action("view", 0.5)
	_bind_key("view", KEY_V)
	_bind_button("view", JOY_BUTTON_RIGHT_STICK)
	_add_action("item", 0.5)
	_bind_key("item", KEY_F)
	_bind_mouse("item", MOUSE_BUTTON_RIGHT)
	_bind_button("item", JOY_BUTTON_B)
	_bind_button("jump", JOY_BUTTON_A)
	_bind_button("slide", JOY_BUTTON_LEFT_SHOULDER)
	_bind_button("slide", JOY_BUTTON_X)
	_bind_button("pause", JOY_BUTTON_START)
	_bind_button("restart", JOY_BUTTON_BACK)
	_bind_axis("move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_axis("move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_axis("move_forward", JOY_AXIS_LEFT_Y, -1.0)
	_bind_axis("move_back", JOY_AXIS_LEFT_Y, 1.0)
	_bind_axis("slide", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	if Settings != null:
		Settings.overlay_binds()


static func _add_action(action: String, deadzone: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, deadzone)
	else:
		InputMap.action_set_deadzone(action, deadzone)


static func _bind_key(action: String, key: Key) -> void:
	for existing in InputMap.action_get_events(action):
		if existing is InputEventKey and existing.physical_keycode == key:
			return
	var ev := InputEventKey.new()
	ev.physical_keycode = key
	InputMap.action_add_event(action, ev)


static func _bind_mouse(action: String, button: MouseButton) -> void:
	for existing in InputMap.action_get_events(action):
		if existing is InputEventMouseButton and existing.button_index == button:
			return
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)


static func _bind_button(action: String, button: JoyButton) -> void:
	for existing in InputMap.action_get_events(action):
		if existing is InputEventJoypadButton and existing.button_index == button:
			return
	var ev := InputEventJoypadButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)


static func _bind_axis(action: String, axis: JoyAxis, axis_value: float) -> void:
	for existing in InputMap.action_get_events(action):
		if existing is InputEventJoypadMotion and existing.axis == axis and is_equal_approx(existing.axis_value, axis_value):
			return
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = axis_value
	InputMap.action_add_event(action, ev)


func _build_body() -> void:
	shape = CapsuleShape3D.new()
	shape.radius = RADIUS
	shape.height = STAND_H
	collision = CollisionShape3D.new()
	collision.shape = shape
	collision.position.y = STAND_H * 0.5
	add_child(collision)

	head = Node3D.new()
	head.position.y = 1.52
	add_child(head)
	camera = Camera3D.new()
	camera.fov = 82
	camera.near = 0.02
	camera.current = false
	head.add_child(camera)
	left_hand = _make_hand()
	right_hand = _make_hand()
	camera.add_child(left_hand)
	camera.add_child(right_hand)
	left_hand.position = Vector3(-0.34, -0.38, -0.48)
	right_hand.position = Vector3(0.34, -0.38, -0.48)

	mannequin = MannequinScript.new()
	mannequin.tint = player_color
	mannequin.name_text = display_name
	mannequin.hat_id = worn_hat
	mannequin.style_id = worn_style
	mannequin.trail_id = worn_trail
	add_child(mannequin)
	forearm_l = left_hand.get_child(0) as MeshInstance3D
	forearm_r = right_hand.get_child(0) as MeshInstance3D

	ray_l = _side_ray(-1)
	ray_r = _side_ray(1)
	ceil_ray = RayCast3D.new()
	ceil_ray.position = Vector3(0, 0.2, 0)
	ceil_ray.target_position = Vector3(0, STAND_H, 0)
	ceil_ray.collision_mask = 1
	add_child(ceil_ray)
	ahead_ray = RayCast3D.new()
	ahead_ray.position = Vector3(0, 0.35, 0)
	ahead_ray.target_position = Vector3(0, -1.6, -1.25)
	ahead_ray.collision_mask = 1
	add_child(ahead_ray)
	sense_l = _long_ray(-1)
	sense_r = _long_ray(1)
	duct_ray = RayCast3D.new()
	duct_ray.position = Vector3(0, 1.42, 0)
	duct_ray.target_position = Vector3(0, 0, -4.2)
	duct_ray.collision_mask = 1
	add_child(duct_ray)
	pit_ray = RayCast3D.new()
	pit_ray.position = Vector3(0, 0.5, 0)
	pit_ray.target_position = Vector3(0, -2.5, -7.0)
	pit_ray.collision_mask = 1
	add_child(pit_ray)
	block_ray = RayCast3D.new()
	block_ray.position = Vector3(0, 0.55, 0)
	block_ray.target_position = Vector3(0, 0, -1.35)
	block_ray.collision_mask = 1
	add_child(block_ray)
	# Looks ahead and slightly down so a higher lip reads, and a same-height gap does not.
	rise_ray = RayCast3D.new()
	rise_ray.position = Vector3(0, 0.9, -0.2)
	rise_ray.target_position = Vector3(0, -0.35, -6.4)
	rise_ray.collision_mask = 1
	add_child(rise_ray)
	grab_ray = RayCast3D.new()
	grab_ray.collision_mask = 1 | 4
	grab_ray.enabled = true
	add_child(grab_ray)


func _long_ray(side: int) -> RayCast3D:
	var ray := RayCast3D.new()
	ray.position = Vector3(0, 1.0, 0)
	ray.target_position = Vector3(side * 4.4, 0, 0)
	ray.collision_mask = 1
	add_child(ray)
	return ray


func _side_ray(side: int) -> RayCast3D:
	var ray := RayCast3D.new()
	# Origin stays inside the capsule so a hugged wall never swallows the ray.
	ray.position = Vector3(side * 0.05, 0.95, 0)
	ray.target_position = Vector3(side * 1.2, 0, 0)
	ray.collision_mask = 1
	add_child(ray)
	return ray


func _make_hand() -> Node3D:
	var pivot := Node3D.new()
	var arm := MeshInstance3D.new()
	var arm_mesh := BoxMesh.new()
	arm_mesh.size = Vector3(0.075, 0.075, 0.34)
	arm.mesh = arm_mesh
	arm.position = Vector3(0, 0, -0.1)
	arm.material_override = _mat(Color("241f1c"))
	var palm := MeshInstance3D.new()
	var palm_mesh := BoxMesh.new()
	palm_mesh.size = Vector3(0.1, 0.05, 0.11)
	palm.mesh = palm_mesh
	palm.position = Vector3(0, -0.01, -0.3)
	palm.material_override = _mat(Color("d7c4ae"))
	pivot.add_child(arm)
	pivot.add_child(palm)
	return pivot


func _mat(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.85
	return mat


func _apply_color() -> void:
	if mannequin and mannequin.has_method("set_tint"):
		mannequin.set_tint(player_color)
	if forearm_l:
		forearm_l.material_override = _mat(player_color)
	if forearm_r:
		forearm_r.material_override = _mat(player_color)


func _unhandled_input(event: InputEvent) -> void:
	if not view_player:
		return
	var captured := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not finished:
			if Match.battle and Match.started and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				_use_item()
				get_viewport().set_input_as_handled()
			else:
				_engage()
	elif event.is_action_pressed("ui_cancel"):
		_release_mouse()
	elif event.is_action_pressed("pause"):
		if captured:
			_release_mouse()
		elif not finished:
			_engage()
	elif event.is_action_pressed("jump") and not captured and not finished:
		suppress_jump = true
		_engage()
	elif event.is_action_pressed("view") and not event.is_echo():
		_toggle_view()
		get_viewport().set_input_as_handled()
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not cinematic:
		var sens := Settings.mouse_sens
		var y_sign := -1.0 if Settings.invert_y else 1.0
		yaw -= event.relative.x * 0.00215 * sens
		pitch = clampf(pitch - event.relative.y * 0.00215 * sens * y_sign, deg_to_rad(-85), deg_to_rad(85))
		rotation.y = yaw
		head.rotation.x = pitch


func _engage() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var owner := get_viewport().gui_get_focus_owner()
	if owner:
		owner.release_focus()


func _release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _toggle_view() -> void:
	if not view_player:
		return
	third_person = not third_person
	_cam_held = false
	Profile.set_third_person(third_person)
	_apply_view()
	message = "Third person" if third_person else "First person"
	message_time = 0.6
	_sfx("click", -10.0)


func _character_hands() -> bool:
	return mannequin != null and mannequin.has_method("has_mascot") and bool(mannequin.has_mascot())


func _sync_block_hands() -> void:
	# The cube arms only stand in until the character model is on screen.
	var show_blocks := not third_person and not _character_hands()
	for hand in [left_hand, right_hand]:
		if hand == null:
			continue
		hand.visible = not third_person
		for child in hand.get_children():
			if child == _item_mesh:
				continue
			if child is MeshInstance3D:
				(child as MeshInstance3D).visible = show_blocks


func _apply_view() -> void:
	if not view_player or mannequin == null:
		return
	mannequin.visible = true
	if mannequin.has_method("set_first_person"):
		mannequin.set_first_person(not third_person)
	var tag = mannequin.get("name_tag")
	if tag != null:
		tag.visible = third_person
	_sync_block_hands()
	_seat_item()
	if not third_person:
		camera.near = 0.06
		camera.top_level = false
		_seat_eye(false)
	else:
		camera.near = 0.05


func _seat_item() -> void:
	if _item_mesh == null:
		return
	if third_person or not view_player:
		if _item_mesh.get_parent() != self:
			_item_mesh.reparent(self)
		_item_mesh.position = Vector3(0.36, 1.02, 0.12) if third_person else Vector3(0.32, 1.15, -0.22)
		return
	if right_hand != null:
		if _item_mesh.get_parent() != right_hand:
			_item_mesh.reparent(right_hand)
		_item_mesh.position = Vector3(0.02, -0.02, -0.48)


func _seat_eye(low: bool) -> void:
	# Stay in the eyes. A slide only tips the look a little.
	camera.position = Vector3(0.0, 0.02, -0.04)
	camera.rotation.x = -0.16 if low else 0.0
	camera.rotation.y = 0.0


func _chase_camera(delta: float, roll: float) -> void:
	if not is_inside_tree():
		return
	var focus: Vector3 = head.global_position
	var back: Vector3 = head.global_transform.basis.z
	if back.length() < 0.01:
		back = Vector3(0, 0, 1)
	back = back.normalized()
	var start := focus + back * 0.42
	var dest := focus + back * 3.55 + Vector3.UP * 0.22
	var placed := dest
	var world := get_world_3d()
	if world != null:
		var query := PhysicsRayQueryParameters3D.create(start, dest)
		query.collision_mask = 1
		var hit := world.direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			var travel := dest - start
			var span := travel.length()
			if span > 0.05:
				var hit_pos: Vector3 = hit.position
				var along := clampf(start.distance_to(hit_pos) - 0.28, 0.2, span)
				placed = start + travel / span * along
	if not _cam_held:
		_cam_hold = placed
		_cam_held = true
	else:
		_cam_hold = _cam_hold.lerp(placed, 1.0 - exp(-11.0 * delta))
	camera.top_level = true
	camera.global_position = _cam_hold
	var to_focus := focus - camera.global_position
	if to_focus.length() > 0.08:
		var up := Vector3.UP
		if absf(to_focus.normalized().dot(Vector3.UP)) > 0.96:
			up = head.global_transform.basis.x
		camera.look_at(focus, up)
		camera.rotate_object_local(Vector3.FORWARD, roll)


func _pad_look(delta: float) -> void:
	var rx := 0.0
	var ry := 0.0
	var strongest := 0.0
	for device in Input.get_connected_joypads():
		var x := Input.get_joy_axis(device, JOY_AXIS_RIGHT_X)
		var y := Input.get_joy_axis(device, JOY_AXIS_RIGHT_Y)
		var mag := absf(x) + absf(y)
		if mag > strongest:
			strongest = mag
			rx = x
			ry = y
	rx = _look_curve(rx)
	ry = _look_curve(ry)
	if rx == 0.0 and ry == 0.0:
		return
	var sens := Settings.pad_sens
	var y_sign := -1.0 if Settings.invert_y else 1.0
	yaw -= rx * 3.2 * delta * sens
	pitch = clampf(pitch - ry * 2.4 * delta * sens * y_sign, deg_to_rad(-85), deg_to_rad(85))
	rotation.y = yaw
	head.rotation.x = pitch


func _look_curve(value: float) -> float:
	var mag := absf(value)
	var dead := Settings.stick_deadzone
	if mag < dead:
		return 0.0
	var t := (mag - dead) / maxf(1.0 - dead, 0.05)
	return signf(value) * t * t


func _trigger_slide() -> bool:
	for device in Input.get_connected_joypads():
		if Input.get_joy_axis(device, JOY_AXIS_TRIGGER_RIGHT) > 0.55:
			return true
	return false


func _bot() -> bool:
	return is_bot


func _physics_process(delta: float) -> void:
	if not is_local():
		if has_net:
			global_position = global_position.lerp(net_pos, 1.0 - exp(-14.0 * delta))
			rotation.y = lerp_angle(rotation.y, net_yaw, 1.0 - exp(-14.0 * delta))
			head.rotation.x = lerp_angle(head.rotation.x, net_pitch, 1.0 - exp(-14.0 * delta))
		return

	if not Match.started:
		suppress_jump = false
		velocity.x = move_toward(velocity.x, 0.0, 50.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 50.0 * delta)
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		var y_before := velocity.y
		move_and_slide()
		_bump_runners(y_before, delta)
		_sync_net()
		return

	if eliminated:
		zipping = false
		sliding = false
		if hanging:
			_clear_hang()
		_leave_wall()
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		move_and_slide()
		_sync_net()
		return

	if not finished:
		race_time += delta
	message_time = maxf(0.0, message_time - delta)
	emote_time = maxf(0.0, emote_time - delta)
	if emote_time <= 0.0:
		emote = ""
	ban_time = maxf(0.0, ban_time - delta)
	stunned = maxf(0.0, stunned - delta)
	shove_lock = maxf(0.0, shove_lock - delta)
	bump_lock = maxf(0.0, bump_lock - delta)
	boost_lock = maxf(0.0, boost_lock - delta)
	boost_time = maxf(0.0, boost_time - delta)
	pop_lock = maxf(0.0, pop_lock - delta)
	grab_lock = maxf(0.0, grab_lock - delta)
	mercy = maxf(0.0, mercy - delta)
	if is_on_floor():
		air_time = 0.0
		coyote = 0.14
	else:
		air_time += delta
		coyote = maxf(0.0, coyote - delta)

	var playing := _bot() or (view_player and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)
	if _bot() and not Match.battle and not finished:
		yaw = 0.0
		rotation.y = 0.0

	var jump_pressed := false
	var slide_held := false
	var wish := Vector3.ZERO
	if playing and stunned <= 0.0 and not finished and not eliminated:
		if _bot():
			wish = _bot_wish(delta)
			jump_pressed = _bot_wants_jump(delta)
			slide_held = _bot_wants_slide()
			if Match.battle:
				_battle_use_along_race(delta)
		else:
			var stick := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			wish = (global_transform.basis * Vector3(stick.x, 0, stick.y))
			if wish.length() > 1.0:
				wish = wish.normalized()
			jump_pressed = Input.is_action_just_pressed("jump")
			if suppress_jump:
				jump_pressed = false
				suppress_jump = false
			slide_held = Input.is_action_pressed("slide") or _trigger_slide()
			_pad_look(delta)
			if Match.battle and Match.started and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("item"):
				_use_item()
	else:
		suppress_jump = false

	if jump_pressed:
		jump_buffer = 0.12
	else:
		jump_buffer = maxf(0.0, jump_buffer - delta)

	if hanging:
		_update_hang(delta, wish, slide_held)
		if not finished and not eliminated and global_position.y < checkpoint_pos.y - FALL_DEPTH:
			_respawn()
		wall_time = 0.0
		_sync_net()
		return

	if zipping:
		_ride_zip(delta, jump_pressed)
		if not finished and not eliminated and global_position.y < checkpoint_pos.y - FALL_DEPTH:
			_respawn()
		wall_time = 0.0
		_sync_net()
		return

	ceil_ray.force_raycast_update()
	var blocked_stand := ceil_ray.is_colliding()
	var speed_h := horizontal_speed()
	if blocked_stand:
		if not sliding and speed_h > 6.2:
			var flat := Vector2(velocity.x, velocity.z)
			flat = flat.normalized() * maxf(flat.length(), SLIDE_SPEED)
			velocity.x = flat.x
			velocity.z = flat.y
		sliding = true
	elif slide_held and is_on_floor() and (sliding or speed_h > 6.2):
		if not sliding:
			var flat := Vector2(velocity.x, velocity.z)
			if flat.length() > 0.2:
				flat = flat.normalized() * maxf(flat.length(), SLIDE_SPEED)
				velocity.x = flat.x
				velocity.z = flat.y
		sliding = true
	elif is_on_floor():
		sliding = false
	_apply_height(SLIDE_H if sliding else STAND_H)

	if finished and glide_left > 0.0:
		_glide_finish(delta)
	elif wall_running:
		_maintain_wall(delta)
	elif boost_time > 0.0:
		_ride_boost(delta, wish)
	else:
		var icy := _on_ice()
		if icy:
			ice_hold = 0.16
		else:
			ice_hold = maxf(0.0, ice_hold - delta)
		var slick := icy or (sliding and ice_hold > 0.0)
		var carried := horizontal_speed() if slick else -1.0
		if icy:
			var push := 0.0
			for i in get_slide_collision_count():
				var hit := get_slide_collision(i)
				if hit == null or hit.get_normal().y < 0.35:
					continue
				var body: Object = hit.get_collider()
				if body != null and body.is_in_group("ice"):
					push = float(body.get_meta("push", 0.0))
					break
			velocity.x += push * delta
		elif _on_belt():
			var belt := _floor_body()
			var shove_x := float(belt.get_meta("push", 0.0)) if belt != null else 0.0
			velocity.x += shove_x * delta
			velocity.z = minf(velocity.z, -13.5)
		if sliding and is_on_floor():
			if slick:
				slide_time = 0.0
				slick_speed = maxf(slick_speed, carried)
				if wish.length() > 0.05 and stunned <= 0.0 and bump_lock <= 0.0:
					_steer_slide(wish, delta)
			else:
				slick_speed = 0.0
				_slide_decay(delta, wish)
		else:
			if not slick:
				slick_speed = 0.0
			if is_on_floor() or not sliding:
				slide_time = 0.0
			if is_on_floor():
				_friction(delta, slick)
			if wish.length() > 0.05 and stunned <= 0.0 and bump_lock <= 0.0 and not sliding:
				var accel := 12.0 if slick else (GROUND_ACCEL if is_on_floor() else AIR_ACCEL)
				if slick and _bot():
					accel = 28.0
				var cap := bot_speed if _bot() else RUN_SPEED
				_accelerate(wish.normalized(), cap, accel, delta)
			elif sliding and wish.length() > 0.05 and stunned <= 0.0 and bump_lock <= 0.0:
				_steer_slide(wish, delta)
		if sliding and slick and slick_speed > 1.0:
			carried = maxf(carried, slick_speed)
		if slick and carried > 1.0:
			var kept := Vector2(velocity.x, velocity.z)
			if kept.length() < carried:
				if kept.length() < 0.08:
					kept = Vector2(0.0, -1.0)
				kept = kept.normalized() * carried
				velocity.x = kept.x
				velocity.z = kept.y
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		_try_attach()

	if jump_buffer > 0.0 and stunned <= 0.0 and not finished:
		if wall_running:
			velocity += wall_normal * WALL_KICK
			velocity.y = WALL_JUMP_V
			_leave_wall()
			jump_buffer = 0.0
			coyote = 0.0
			_sfx("wall", -4.0, 1.05)
		elif coyote > 0.0:
			velocity.y = JUMP_V
			coyote = 0.0
			jump_buffer = 0.0
			air_time = 0.0
			_sfx("jump", -6.0)

	var was_floor := is_on_floor()
	if not wall_running and _drift.length_squared() > 0.0:
		velocity += _drift * delta
	_drift = Vector3.ZERO
	if finished and glide_left <= 0.0 and horizontal_speed() > 0.05:
		velocity.x = 0.0
		velocity.z = 0.0
	if finished and glide_left <= 0.0 and not Match.battle:
		var left := angle_difference(rotation.y, PI)
		rotation.y += clampf(left, -delta * 5.0, delta * 5.0)
		yaw = rotation.y
		if _cheer_queued and not _cheered and absf(left) < 0.35:
			_cheered = true
			celebrate()
	if _on_chute() and not finished:
		if velocity.z > -14.0:
			velocity.z = -14.0
		velocity.z -= 20.0 * delta
		if velocity.z < -26.0:
			velocity.z = -26.0
	if dash_time > 0.0 and not finished:
		dash_time = maxf(0.0, dash_time - delta)
		var steer := dash_dir
		if wish.length() > 0.2:
			steer = (dash_dir * 0.78 + wish.normalized() * 0.22).normalized()
			dash_dir = steer
		velocity.x = steer.x * 16.5
		velocity.z = steer.z * 16.5
	var y_before := velocity.y
	move_and_slide()
	_bump_runners(y_before, delta)
	_kick_bumpers()
	if is_on_floor() and not was_floor and velocity.y <= 0.1 and air_time > 0.16:
		land_dip = 0.12
		_sfx("land", -5.0)
	elif is_on_floor() and not was_floor:
		land_dip = 0.12
	if is_on_floor() and wall_running:
		_leave_wall()
	_try_grab()

	if global_position.y < checkpoint_pos.y - FALL_DEPTH:
		if Match.battle and finished:
			global_position = respawn_point()
			velocity = Vector3.ZERO
		elif not finished and not eliminated:
			_respawn()
	elif _bot() and not finished and not eliminated and global_position.y < checkpoint_pos.y - 8.0:
		_respawn()

	if lift > 0.0:
		velocity.y += 64.0 * delta
		velocity.y = minf(velocity.y, 16.0)
		lift = maxf(0.0, lift - delta)

	if _bot():
		_bot_recover(delta)

	if wall_running:
		wall_time += delta
	else:
		wall_time = 0.0
	_play_steps(delta)
	if Match.battle:
		_sync_battle_visuals()
	_sync_net()


func _process(delta: float) -> void:
	if not view_player:
		return
	var spd := horizontal_speed()
	if is_on_floor() and not sliding and spd > 1.2:
		run_cycle += delta * spd * 1.2
	elif wall_running:
		run_cycle += delta * 14.0
	_sync_block_hands()
	_animate_hands(delta)
	var target_roll := deg_to_rad(-14.0 * float(wall_side)) if wall_running else clampf(-velocity.x, -8.0, 8.0) * 0.012
	if not Settings.tilt:
		target_roll = 0.0
	land_dip = move_toward(land_dip, 0.0, delta * 0.55)
	fov_kick = move_toward(fov_kick, 0.0, delta * 14.0)
	var eye := 0.44 if sliding else 1.52
	# Slide-jump keeps the low capsule. In the open, first person stands the
	# camera up with the jump. Under a low roof it stays in the crouch.
	if not third_person and not is_on_floor() and not _ceiling_close():
		eye = 1.52
	# Wait until the body is already in the slide pose, then drop the eye.
	# Dropping through the standing mesh fills the screen.
	if not third_person and sliding and is_on_floor() and not _slide_posed():
		eye = 1.52
	head.position.y = eye - land_dip
	if third_person:
		_chase_camera(delta, target_roll)
	else:
		if camera.top_level:
			camera.top_level = false
		_seat_eye(sliding and is_on_floor() and _slide_posed())
		camera.rotation.z = lerp_angle(camera.rotation.z, target_roll, 1.0 - exp(-8.0 * delta))
	if finished and glide_left <= 0.0 and not Match.battle:
		_open_finish_view()
		camera.current = false
	var widen := 0.4 if third_person else 0.65
	var base := Settings.fov * (0.875 if third_person else 1.0)
	camera.fov = base + minf(spd, 14.0) * widen + fov_kick


func _slide_posed() -> bool:
	if mannequin != null and mannequin.has_method("slide_posed"):
		return bool(mannequin.call("slide_posed"))
	return true


func shove(impulse: Vector3, label: String = "Hammer") -> void:
	if shove_lock > 0.0 or finished:
		return
	shove_lock = 0.75
	zipping = false
	_clear_hang()
	grab_lock = 0.35
	velocity = impulse
	stunned = 0.35
	_leave_wall()
	message = label
	message_time = 0.55
	_sfx("hit", -3.0, 1.0, -1.0, true)
	_peel_from_runners()


func _peel_from_runners() -> void:
	for node in get_tree().get_nodes_in_group("runners"):
		if node == self:
			continue
		var away := _away_from(node)
		var dist := Vector2(global_position.x - node.global_position.x, global_position.z - node.global_position.z).length()
		var gap := (RADIUS * 2.0 + 0.08) - dist
		if gap > 0.0:
			global_position += away * gap * 0.55
		velocity.x += away.x * 1.8
		velocity.z += away.z * 1.8


func nudge(push: Vector3) -> void:
	if finished or not is_local() or nudge_lock > 0.0:
		return
	nudge_lock = 0.18
	velocity.x += push.x
	velocity.z += push.z


func _bump_runners(y_before: float, delta: float) -> void:
	touch_lock = maxf(0.0, touch_lock - delta)
	nudge_lock = maxf(0.0, nudge_lock - delta)
	var bumped := false
	for i in get_slide_collision_count():
		var hit := get_slide_collision(i)
		if hit == null:
			continue
		var body: Node = hit.get_collider() as Node
		if body == null or body == self or not body.is_in_group("runners"):
			continue
		var normal := hit.get_normal()
		if normal.y > 0.2:
			velocity.y = minf(velocity.y, maxf(y_before, 0.0))
		var away := _away_from(body)
		var dist := Vector2(global_position.x - body.global_position.x, global_position.z - body.global_position.z).length()
		var gap := (RADIUS * 2.0 + 0.08) - dist
		if gap > 0.0:
			global_position += away * gap * 0.55
		if touch_lock > 0.0 or shove_lock > 0.0 or finished:
			continue
		var flat := Vector3(velocity.x, 0.0, velocity.z)
		var closing := -flat.dot(away)
		if closing < 0.35:
			continue
		var rebound := minf(closing * 0.45 + 1.3, 3.0)
		velocity.x += away.x * rebound
		velocity.z += away.z * rebound
		if body.has_method("nudge"):
			body.nudge(-away * 1.15)
		bumped = true
	if bumped:
		touch_lock = 0.16


func _away_from(body: Node3D) -> Vector3:
	var away := Vector3(global_position.x - body.global_position.x, 0.0, global_position.z - body.global_position.z)
	if away.length() < 0.05:
		var side := 1.0 if posmod(spawn_slot, 2) == 0 else -1.0
		away = Vector3(side, 0.0, 0.25 if posmod(spawn_slot, 4) < 2 else -0.25)
	return away.normalized()


func _kick_bumpers() -> void:
	if bump_lock > 0.0 or finished:
		return
	for i in get_slide_collision_count():
		var hit := get_slide_collision(i)
		if hit == null:
			continue
		var col: Node3D = hit.get_collider() as Node3D
		if col == null or not col.is_in_group("bumper"):
			continue
		var normal := hit.get_normal()
		if normal.y > 0.62:
			continue
		var away := Vector3(normal.x, 0.0, normal.z)
		if away.length() < 0.2:
			var origin: Vector3 = col.global_position
			var from := global_position - origin
			away = Vector3(from.x, 0.0, from.z)
		if away.length() < 0.05:
			away = Vector3(1.0, 0.0, 0.0)
		away = away.normalized()
		var flat := Vector3(velocity.x, 0.0, velocity.z)
		var tangent := flat - away * flat.dot(away)
		var speed := clampf(maxf(flat.length(), 14.0), 14.0, 18.0)
		var kick := away * speed + tangent * 0.25
		velocity.x = kick.x
		velocity.z = kick.z
		velocity.y = maxf(velocity.y, 6.4)
		bump_lock = 0.18
		_clear_hang()
		_leave_wall()
		if col.has_method("boop"):
			col.boop()
		message = "Bumper"
		message_time = 0.4
		_sfx("spring", -5.0, 0.78)
		return


func drift(push: Vector3) -> void:
	if finished:
		return
	_drift += push


func pop() -> void:
	if finished or pop_lock > 0.0:
		return
	pop_lock = 0.4
	_clear_hang()
	velocity.y = maxf(velocity.y, 11.5)
	message = "Vent"
	message_time = 0.6
	_sfx("vent", -6.0, 1.0)


func spring() -> void:
	if boost_lock > 0.0 or finished:
		return
	boost_lock = 0.6
	fov_kick = 5.0
	_clear_hang()
	_leave_wall()
	var flat := Vector2(velocity.x, velocity.z)
	var dir := Vector2(0, -1)
	if flat.length() > 1.2:
		dir = flat.normalized().lerp(Vector2(0, -1), 0.62).normalized()
	var speed := 6.8
	velocity.x = dir.x * speed
	velocity.z = dir.y * speed
	velocity.y = 17.5
	message = "Bounce"
	message_time = 0.7
	_sfx("spring", -1.0, 1.0)


func kick() -> void:
	if boost_lock > 0.0 or finished:
		return
	boost_lock = 0.4
	boost_time = 0.42
	boost_back = false
	boost_speed = 16.0
	fov_kick = 4.0
	_clear_hang()
	velocity.z = minf(velocity.z, -16.0)
	# Tunnel pads shove along the floor. They do not pop you into the ceiling.
	velocity.y = minf(velocity.y, 0.0)
	message = "Boost"
	message_time = 0.4
	_sfx("boost", -8.0, 1.28, 0.14, true)


func ring() -> void:
	if finished:
		return
	if boost_lock > 0.0 and boost_time <= 0.0:
		return
	fov_kick = 4.0
	_clear_hang()
	# A little extra down the roof. The jump's height stays whatever it already was.
	if velocity.z > -13.5:
		velocity.z = minf(velocity.z - 5.0, -13.5)
	velocity.x = move_toward(velocity.x, 0.0, 1.6)
	if not boost_back and boost_time < 0.26:
		boost_time = 0.26
		boost_back = false
		boost_speed = maxf(boost_speed, 13.5)
	boost_lock = maxf(boost_lock, 0.3)
	message = "Ring"
	message_time = 0.45
	_sfx("boost", -6.0, 1.35, 0.14)


func boost_along() -> void:
	if finished or boost_lock > 0.0 or not wall_running:
		return
	var tangent := wall_normal.cross(Vector3.UP).normalized()
	if tangent.z > 0.0:
		tangent = -tangent
	boost_lock = 0.28
	boost_time = 0.4
	boost_back = false
	boost_speed = 15.5
	fov_kick = 3.5
	var speed := maxf(Vector3(velocity.x, 0.0, velocity.z).dot(tangent), boost_speed)
	velocity.x = tangent.x * speed - wall_normal.x * 2.2
	velocity.z = tangent.z * speed - wall_normal.z * 2.2
	message = "Boost"
	message_time = 0.35
	_sfx("boost", -6.0, 1.15, 0.16, true)


func boost(backward: bool = false) -> void:
	if boost_lock > 0.0 or finished:
		return
	# Bots have no reason to hop the reverse pads, so those do not shove them.
	if backward and is_bot:
		return
	_clear_hang()
	_leave_wall()
	if backward:
		boost_lock = 0.55
		boost_time = 0.32
		boost_back = true
		boost_speed = 7.5
		fov_kick = 3.0
		velocity.z = maxf(velocity.z + 9.0, 7.5)
		velocity.y = maxf(velocity.y, 2.2)
		message = "Back"
		message_time = 0.45
		_sfx("boost", -6.0, 0.72, 0.22, true)
		return
	boost_lock = 0.5
	boost_time = 0.62
	boost_back = false
	boost_speed = 22.0
	fov_kick = 8.0
	velocity.z = minf(velocity.z, -22.0)
	velocity.y = maxf(velocity.y, 3.2)
	message = "Boost"
	message_time = 0.55
	_sfx("boost", -3.0, 1.0, 0.32, true)


func _ride_boost(delta: float, wish: Vector3) -> void:
	if boost_back:
		velocity.z = maxf(velocity.z, boost_speed)
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
	else:
		if velocity.z > -boost_speed:
			velocity.z = move_toward(velocity.z, -boost_speed, 70.0 * delta)
		if wish.length() > 0.05:
			velocity.x = move_toward(velocity.x, wish.x * 3.2, 14.0 * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, 8.0 * delta)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta


func give_item(id: String) -> bool:
	if not Match.battle or not Match.started or finished or held_item != "":
		return false
	if Items.label_of(id) == "":
		return false
	held_item = id
	message = Items.label_of(id)
	message_time = 0.7
	if view_player:
		Sfx.play("check", -4.0)
	_show_held()
	return true


func strike(impulse: Vector3, label: String = "Hit") -> void:
	if finished or mercy > 0.0:
		return
	if Match.battle and guard_up:
		guard_up = false
		mercy = 0.45
		message = "Blocked"
		message_time = 0.55
		_sfx("grab", -4.0)
		_sync_battle_visuals()
		return
	shove(impulse, label)


func _use_item() -> void:
	if held_item == "" or finished or not Match.started:
		return
	var id := held_item
	held_item = ""
	_show_held()
	match id:
		"dash":
			_cast_dash()
		"brick":
			_cast_brick()
		"slick":
			_cast_slick()
		"guard":
			guard_up = true
			message = "Guard"
			message_time = 0.55
			_sfx("grab", -6.0)
		"gust":
			_cast_gust()
	_sync_battle_visuals()


func _cast_dash() -> void:
	dash_dir = _aim_forward()
	dash_time = 0.85
	fov_kick = 8.0
	_clear_hang()
	_leave_wall()
	velocity.y = maxf(velocity.y, 3.4)
	message = "Dash"
	message_time = 0.6
	_sfx("boost", -3.0)


func _cast_brick() -> void:
	var dir := _aim_forward()
	if _bot():
		var foe = _nearest_foe()
		if foe != null:
			var aim: Vector3 = foe.global_position - global_position
			aim.y = 0.0
			var travel := clampf(aim.length() / 17.0, 0.0, 0.55)
			aim += Vector3(foe.velocity.x, 0.0, foe.velocity.z) * travel
			if aim.length() > 0.2:
				dir = aim.normalized()
	var brick := BrickScript.new()
	brick.velocity = dir * 17.0
	brick.thrower = self
	get_tree().current_scene.add_child(brick)
	brick.global_position = global_position + dir * 1.05 + Vector3(0, 0.8, 0)
	_sfx("wall", -8.0, 1.15)


func _cast_slick() -> void:
	var slick := SlickScript.new()
	slick.thrower = self
	get_tree().current_scene.add_child(slick)
	slick.global_position = global_position - _aim_forward() * 1.15 + Vector3(0, 0.02, 0)
	_sfx("slide", -6.0, 0.8)


func _cast_gust() -> void:
	var hit := false
	for runner in get_tree().get_nodes_in_group("runners"):
		if runner == self or not runner.has_method("strike"):
			continue
		var gap: Vector3 = runner.global_position - global_position
		gap.y = 0.0
		if gap.length() > 5.2 or gap.length() < 0.05:
			continue
		runner.strike(gap.normalized() * 12.0 + Vector3(0, 7.0, 0), "Gust")
		hit = true
	message = "Gust" if hit else "Whiff"
	message_time = 0.7
	_sfx("vent", -5.0)


func _lose_balloon(label: String) -> void:
	if finished:
		return
	balloons = maxi(0, balloons - 1)
	mercy = 1.45
	if balloons <= 0:
		finished = true
		message = "Out"
	else:
		message = "%s    %d left" % [label, balloons]
	message_time = 0.7
	_sync_battle_visuals()


func _battle_drop() -> void:
	velocity = Vector3.ZERO
	_leave_wall()
	_clear_hang()
	sliding = false
	slide_time = 0.0
	stunned = 0.45
	global_position = respawn_point()
	if finished:
		return
	if mercy > 0.0:
		mercy = maxf(mercy, 0.7)
		return
	if guard_up:
		guard_up = false
		mercy = 0.6
		message = "Blocked"
		message_time = 0.55
		_sfx("grab", -4.0)
		_sync_battle_visuals()
		return
	_lose_balloon("Fell")
	_sfx("land", -6.0, 0.82)


func _battle_use_along_race(delta: float) -> void:
	battle_wait = maxf(0.0, battle_wait - delta)
	if held_item == "" or battle_wait > 0.0:
		return
	if _battle_should_use(_nearest_foe()):
		_use_item()
		battle_wait = 0.85


func _battle_wish(delta: float) -> Vector3:
	_bot_prepare()
	battle_wait = maxf(0.0, battle_wait - delta)
	battle_jump = false
	if battle_anchor == Vector3.ZERO:
		battle_anchor = global_position
	if global_position.distance_to(battle_anchor) < 0.3:
		battle_stuck += delta
	else:
		battle_stuck = 0.0
		battle_anchor = global_position
	var foe = _nearest_foe()
	var target := battle_spot if battle_spot != Vector3.ZERO else global_position + Vector3(0, 0, -4)
	if held_item == "":
		var crate = _nearest_crate()
		if crate != null:
			target = crate.global_position
		elif battle_stuck > 1.1 or global_position.distance_to(target) < 1.2:
			battle_spot = _court_point()
			target = battle_spot
	else:
		if foe != null:
			target = foe.global_position
		if battle_wait <= 0.0 and _battle_should_use(foe):
			_use_item()
			battle_wait = 0.7
	if battle_stuck > 1.7:
		battle_stuck = 0.0
		battle_spot = _court_point()
		target = battle_spot
		battle_jump = true
	var flat := target - global_position
	flat.y = 0.0
	block_ray.force_raycast_update()
	if block_ray.is_colliding() and block_ray.get_collision_normal().y < 0.45:
		battle_jump = true
	if flat.length() < 0.4:
		return Vector3.ZERO
	yaw = atan2(-flat.x, -flat.z)
	rotation.y = yaw
	head.rotation.x = 0.0
	return flat.normalized()


func _battle_should_use(foe) -> bool:
	if held_item == "guard":
		return true
	if foe == null:
		return held_item == "slick"
	var dist := global_position.distance_to(foe.global_position)
	var to: Vector3 = foe.global_position - global_position
	to.y = 0.0
	var facing := 1.0
	if to.length() > 0.1:
		facing = _aim_forward().dot(to.normalized())
	match held_item:
		"dash":
			return dist > 4.2 and dist < 14.0
		"brick":
			return dist > 2.4 and dist < 15.0 and facing > 0.35
		"slick":
			return dist < 8.0
		"gust":
			return dist < 4.8
		_:
			return false


func _nearest_foe():
	var best: Node = null
	var best_d := 999.0
	for runner in get_tree().get_nodes_in_group("runners"):
		if runner == self or not runner.has_method("strike"):
			continue
		if bool(runner.finished):
			continue
		var dist := global_position.distance_to(runner.global_position)
		if dist < best_d:
			best_d = dist
			best = runner
	return best


func _nearest_crate():
	var best: Node = null
	var best_d := 999.0
	for crate in get_tree().get_nodes_in_group("crate"):
		if not crate.has_method("is_awake") or not crate.is_awake():
			continue
		var dist := global_position.distance_to(crate.global_position)
		if dist < best_d:
			best_d = dist
			best = crate
	return best


func _court_point() -> Vector3:
	var ang := _bot_rng.randf() * TAU
	var dist := _bot_rng.randf_range(2.0, 9.5)
	return Vector3(sin(ang) * dist, 0.05, cos(ang) * dist)


func _aim_forward() -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	if forward.length() < 0.05:
		return Vector3(0, 0, -1)
	return forward.normalized()


func turned_around() -> bool:
	if finished:
		return false
	# The roof runs toward -Z. The warning is for turning around and running that way.
	var aim := _aim_forward()
	if aim.z <= 0.42:
		return false
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	return flat.dot(aim) > 1.6


func _build_battle_gear() -> void:
	if not Match.battle:
		return
	_guard_mesh = MeshInstance3D.new()
	var shell := SphereMesh.new()
	shell.radius = 0.78
	shell.height = 1.56
	_guard_mesh.mesh = shell
	_guard_mesh.position = Vector3(0, 0.9, 0)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.55, 0.78, 1.0, 0.28)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.15
	glass.emission_enabled = true
	glass.emission = Color(0.45, 0.72, 1.0)
	glass.emission_energy_multiplier = 0.45
	_guard_mesh.material_override = glass
	_guard_mesh.visible = false
	add_child(_guard_mesh)
	_item_mesh = MeshInstance3D.new()
	_item_mesh.visible = false
	if view_player:
		right_hand.add_child(_item_mesh)
		_item_mesh.position = Vector3(0.02, -0.02, -0.48)
	else:
		add_child(_item_mesh)
		_item_mesh.position = Vector3(0.32, 1.15, -0.22)
	_seat_item()


func _show_held() -> void:
	if _item_mesh == null:
		return
	if _shown_item == held_item:
		_item_mesh.visible = held_item != ""
		return
	_shown_item = held_item
	_item_mesh.visible = held_item != ""
	if held_item == "":
		return
	match held_item:
		"brick":
			var box := BoxMesh.new()
			box.size = Vector3(0.14, 0.09, 0.2)
			_item_mesh.mesh = box
			_item_mesh.material_override = _mat(Color("c4473a"))
		"slick":
			var box := BoxMesh.new()
			box.size = Vector3(0.18, 0.04, 0.18)
			_item_mesh.mesh = box
			_item_mesh.material_override = _mat(Color("2a2c30"))
		"guard":
			var sphere := SphereMesh.new()
			sphere.radius = 0.08
			sphere.height = 0.16
			_item_mesh.mesh = sphere
			_item_mesh.material_override = _mat(Color("7eb6e8"))
		"gust":
			var sphere := SphereMesh.new()
			sphere.radius = 0.09
			sphere.height = 0.18
			_item_mesh.mesh = sphere
			_item_mesh.material_override = _mat(Color("f4efe6"))
		_:
			var cap := CapsuleMesh.new()
			cap.radius = 0.05
			cap.height = 0.2
			_item_mesh.mesh = cap
			_item_mesh.material_override = _mat(Color("e0a106"))


func _sync_battle_visuals() -> void:
	if _guard_mesh:
		_guard_mesh.visible = guard_up
	for i in _balloon_meshes.size():
		_balloon_meshes[i].visible = i < balloons
	if not view_player and mannequin:
		mannequin.visible = mercy <= 0.0 or sin(float(Time.get_ticks_msec()) * 0.05) > 0.0
	_show_held()


func _on_ice() -> bool:
	if not is_on_floor():
		return false
	for i in get_slide_collision_count():
		var hit := get_slide_collision(i)
		if hit == null or hit.get_normal().y < 0.35:
			continue
		var col: Object = hit.get_collider()
		if col != null and col.is_in_group("ice"):
			return true
	return false


func _on_belt() -> bool:
	if not is_on_floor():
		return false
	var col := _floor_body()
	return col != null and col.is_in_group("belt")


func _on_chute() -> bool:
	if not is_on_floor():
		return false
	var col := _floor_body()
	return col != null and col.is_in_group("chute")


func _floor_body() -> Object:
	for i in get_slide_collision_count():
		var hit := get_slide_collision(i)
		if hit != null and hit.get_normal().y > 0.55:
			return hit.get_collider()
	return null


func _friction(delta: float, icy: bool = false) -> void:
	var flat := Vector2(velocity.x, velocity.z)
	var speed := flat.length()
	if speed <= 0.001:
		return
	# Ice keeps whatever speed you arrived with. Steering still works.
	var friction := 0.0 if icy else 8.0
	var drop := maxf(speed, 1.0) * friction * delta
	var next := maxf(0.0, speed - drop)
	var scale := next / speed
	velocity.x *= scale
	velocity.z *= scale


func _slide_decay(delta: float, wish: Vector3) -> void:
	slide_time += delta
	var speed := horizontal_speed()
	if speed <= SLIDE_CRAWL + 0.05:
		if wish.length() > 0.05 and stunned <= 0.0:
			_accelerate(wish.normalized(), SLIDE_CRAWL, 18.0, delta)
		return
	# The first moment stays fast. Holding the slide then bleeds it to a crawl.
	var ramp := clampf((slide_time - 0.28) / 0.7, 0.0, 1.0)
	var decel := lerpf(0.8, 18.0, ramp * ramp)
	var next := maxf(SLIDE_CRAWL, speed - decel * delta)
	var scale := next / speed
	velocity.x *= scale
	velocity.z *= scale
	if wish.length() > 0.05 and stunned <= 0.0:
		_steer_slide(wish, delta)


func _steer_slide(wish: Vector3, delta: float) -> void:
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	var speed := flat.length()
	if speed < 0.2:
		return
	var steered := flat.move_toward(wish.normalized() * speed, speed * 5.0 * delta)
	velocity.x = steered.x
	velocity.z = steered.z


func _accelerate(wish: Vector3, wish_speed: float, accel: float, delta: float) -> void:
	var current := velocity.dot(wish)
	var add := wish_speed - current
	if add <= 0.0:
		return
	var gain := minf(accel * delta * wish_speed, add)
	velocity.x += wish.x * gain
	velocity.z += wish.z * gain


func _ceiling_close() -> bool:
	return ceil_ray != null and ceil_ray.is_colliding()


func _apply_height(h: float) -> void:
	if shape == null:
		return
	shape.height = h
	shape.radius = RADIUS
	collision.position.y = h * 0.5


func _try_attach() -> void:
	if wall_running or sliding or is_on_floor() or air_time < 0.05:
		return
	if horizontal_speed() < 4.8:
		return
	ray_l.force_raycast_update()
	ray_r.force_raycast_update()
	for ray: RayCast3D in [ray_l, ray_r]:
		if not ray.is_colliding():
			continue
		var normal: Vector3 = ray.get_collision_normal()
		if absf(normal.y) > 0.35:
			continue
		if not _can_attach(normal):
			continue
		if not _is_tall_wall(ray):
			continue
		wall_running = true
		wall_normal = normal
		wall_side = -1 if ray == ray_l else 1
		wall_time = 0.0
		_sfx("wall", -8.0, 1.12)
		return


func _can_attach(normal: Vector3) -> bool:
	if ban_time <= 0.0:
		return true
	return normal.dot(ban_normal) < 0.45


func _is_tall_wall(ray: RayCast3D) -> bool:
	var saved := ray.position
	# Duct walls top out near 2.9. Real wall-runs and bounce walls keep going well above that.
	ray.position.y = 3.4
	ray.force_raycast_update()
	var tall := ray.is_colliding()
	ray.position = saved
	return tall


func _maintain_wall(delta: float) -> void:
	var ray: RayCast3D = ray_l if wall_side < 0 else ray_r
	ray.force_raycast_update()
	var still := ray.is_colliding() and ray.get_collision_normal().dot(wall_normal) > 0.55
	if not still:
		_leave_wall()
		velocity.y -= GRAVITY * delta
		return
	wall_normal = ray.get_collision_normal()
	var tangent := wall_normal.cross(Vector3.UP).normalized()
	var flat := Vector3(velocity.x, 0, velocity.z)
	if tangent.dot(flat) < 0.0:
		tangent = -tangent
	var along := flat.dot(tangent)
	var cruise := 9.3
	if boost_time > 0.0 and not boost_back:
		cruise = maxf(cruise, boost_speed)
	if along < cruise:
		along = move_toward(along, cruise, 80.0 * delta)
	else:
		along = move_toward(along, cruise, 22.0 * delta)
	along = maxf(along, 9.3)
	velocity.x = tangent.x * along - wall_normal.x * 2.2
	velocity.z = tangent.z * along - wall_normal.z * 2.2
	# A jump onto the wall pops you up, then the run settles instead of climbing away.
	if velocity.y > 2.2:
		velocity.y = move_toward(velocity.y, 2.2, 22.0 * delta)
	else:
		velocity.y = maxf(velocity.y - 8.0 * delta, -1.3)


func _leave_wall() -> void:
	if wall_running:
		ban_normal = wall_normal
		ban_time = 0.35
	wall_running = false
	wall_side = 0


func _try_grab() -> void:
	if hanging or grab_lock > 0.0 or wall_running or sliding or finished or stunned > 0.0:
		return
	if not is_on_floor() and air_time < 0.04:
		return
	if velocity.y > 4.5:
		return
	var flat := Vector3(velocity.x, 0.0, velocity.z)
	var dir := Vector3(0, 0, -1)
	if flat.length() > 0.75:
		dir = flat.normalized()
	else:
		dir = -global_transform.basis.z
		dir.y = 0.0
		if dir.length() < 0.1:
			dir = Vector3(0, 0, -1)
		else:
			dir = dir.normalized()
	var local_dir := global_transform.basis.inverse() * dir
	var probes: Array[Vector3] = [
		local_dir * 1.05,
		local_dir * 0.72,
		local_dir * 0.55 + Vector3(0, -0.28, 0),
	]
	for hand_y in [0.85, 1.15, 1.45, 1.75]:
		for probe in probes:
			grab_ray.position = Vector3(0, float(hand_y), 0)
			grab_ray.target_position = probe
			grab_ray.force_raycast_update()
			if not grab_ray.is_colliding():
				continue
			var normal: Vector3 = grab_ray.get_collision_normal()
			if absf(normal.y) > 0.45:
				continue
			if dir.dot(normal) > -0.05:
				continue
			var hit: Vector3 = grab_ray.get_collision_point()
			var lip: Variant = _lip_at(hit, normal)
			if lip == null:
				continue
			var lip_pos: Vector3 = lip
			var reach := lip_pos.y - global_position.y
			if is_on_floor():
				if reach < 0.8 or reach > 1.85:
					continue
			elif reach < 0.22 or reach > 2.25:
				continue
			if not _open_above(lip_pos):
				continue
			if _close_floor_below(lip_pos, normal):
				continue
			_begin_hang(lip_pos, normal)
			return


func _lip_at(hit: Vector3, normal: Vector3) -> Variant:
	grab_ray.global_position = hit - normal * 0.24 + Vector3(0, 1.2, 0)
	grab_ray.target_position = Vector3(0, -1.65, 0)
	grab_ray.force_raycast_update()
	if not grab_ray.is_colliding():
		return null
	var top_n: Vector3 = grab_ray.get_collision_normal()
	if top_n.y < 0.65:
		return null
	return grab_ray.get_collision_point()


func _open_above(lip: Vector3) -> bool:
	grab_ray.global_position = lip + Vector3(0, 0.25, 0)
	grab_ray.target_position = Vector3(0, 1.65, 0)
	grab_ray.force_raycast_update()
	if not grab_ray.is_colliding():
		return true
	var point: Vector3 = grab_ray.get_collision_point()
	return point.y - lip.y > 1.05


func _close_floor_below(lip: Vector3, normal: Vector3) -> bool:
	grab_ray.global_position = lip + normal * 0.48 + Vector3(0, 0.25, 0)
	grab_ray.target_position = Vector3(0, -3.0, 0)
	grab_ray.force_raycast_update()
	if not grab_ray.is_colliding():
		return false
	var top_n: Vector3 = grab_ray.get_collision_normal()
	if top_n.y < 0.55:
		return false
	var point: Vector3 = grab_ray.get_collision_point()
	return lip.y - point.y < 0.4


func _begin_hang(lip: Vector3, normal: Vector3) -> void:
	_leave_wall()
	sliding = false
	hanging = true
	mantling = false
	hang_time = 0.0
	mantle_time = 0.0
	hang_normal = normal.normalized()
	var face := lip + hang_normal * 0.24
	var feet := face + hang_normal * (RADIUS + 0.06)
	feet.y = lip.y - 1.2
	hang_pos = feet
	_sfx("grab", -6.0)
	global_position = hang_pos
	velocity = Vector3.ZERO
	message = "Space to climb"
	message_time = 0.85


func _update_hang(delta: float, wish: Vector3, slide_held: bool) -> void:
	hang_time += delta
	if mantling:
		mantle_time += delta
		var u := clampf(mantle_time / 0.38, 0.0, 1.0)
		var pos := mantle_from
		if u < 0.55:
			var lift := u / 0.55
			pos.y = lerpf(mantle_from.y, mantle_to.y + 0.08, lift)
		else:
			var slide := (u - 0.55) / 0.45
			pos = mantle_from.lerp(mantle_to, slide)
			pos.y = lerpf(mantle_to.y + 0.08, mantle_to.y, slide)
		global_position = pos
		velocity = Vector3.ZERO
		if u >= 1.0:
			_clear_hang()
			grab_lock = 0.35
			global_position = mantle_to
			velocity = -hang_normal * 3.6
			velocity.y = 0.2
			air_time = 0.0
		return
	global_position = hang_pos
	velocity = Vector3.ZERO
	var away := wish.dot(hang_normal)
	var pull := jump_buffer > 0.0 or (_bot() and hang_time > 0.08)
	var drop := (not _bot()) and (away > 0.55 or slide_held)
	if drop:
		_drop_from_hang()
	elif pull:
		_begin_mantle()
	elif _bot() and hang_time > 1.2:
		_drop_from_hang()


func _begin_mantle() -> void:
	mantling = true
	mantle_time = 0.0
	mantle_from = global_position
	var stand := hang_pos - hang_normal * (RADIUS + 1.05)
	stand.y = hang_pos.y + 1.2
	mantle_to = stand
	jump_buffer = 0.0
	_sfx("grab", -8.0, 0.9)


func _drop_from_hang() -> void:
	var push := hang_normal
	_clear_hang()
	grab_lock = 0.25
	velocity = push * 2.2
	velocity.y = -1.5
	jump_buffer = 0.0


func _clear_hang() -> void:
	hanging = false
	mantling = false
	hang_time = 0.0
	mantle_time = 0.0


func _respawn() -> void:
	falls += 1
	velocity = Vector3.ZERO
	_leave_wall()
	_clear_hang()
	zipping = false
	ban_time = 0.0
	sliding = false
	slide_time = 0.0
	bot_lane_time = 0.0
	bot_jump_wait = 0.0
	bot_gap_set = false
	bot_stall = 0.0
	bot_marked = false
	stunned = 0.5
	global_position = respawn_point()
	message = "Back to the last checkpoint."
	message_time = 0.65
	_sfx("land", -8.0, 0.86)


func respawn_point() -> Vector3:
	var preferred := place_on_roof(checkpoint_pos + _seat_offset(spawn_slot))
	if not _seat_busy(preferred):
		return preferred
	for n in 10:
		var alt := place_on_roof(checkpoint_pos + _seat_offset(n))
		if not _seat_busy(alt):
			return alt
	return place_on_roof(checkpoint_pos + Vector3(0.0, 0.35, 0.0))


func place_on_roof(spot: Vector3) -> Vector3:
	var world := get_world_3d()
	if world == null:
		return spot
	var space := world.direct_space_state
	var best := spot
	var best_d := 999.0
	var found := false
	for dz in range(-2, 8):
		for dx in [-1, 0, 1]:
			var try_at := spot + Vector3(float(dx) * 0.4, 0.0, -float(dz) * 0.45)
			var query := PhysicsRayQueryParameters3D.create(try_at + Vector3(0, 3.2, 0), try_at + Vector3(0, -6.0, 0))
			query.collision_mask = 1
			var hit := space.intersect_ray(query)
			if hit.is_empty():
				continue
			var p: Vector3 = hit.position
			var flat := Vector2(p.x - spot.x, p.z - spot.z).length()
			if not found or flat < best_d:
				found = true
				best_d = flat
				best = Vector3(p.x, p.y + 0.16, p.z)
			if flat < 0.2:
				return best
	return best


func _seat_offset(slot: int) -> Vector3:
	var i := posmod(slot, 10)
	var col := i % 2
	var row := int(i / 2)
	var x := -0.48 if col == 0 else 0.48
	return Vector3(x, 0.16, float(row) * 1.05)


func _seat_busy(spot: Vector3) -> bool:
	for node in get_tree().get_nodes_in_group("runners"):
		if node == self:
			continue
		var flat := Vector2(node.global_position.x - spot.x, node.global_position.z - spot.z)
		if flat.length() < 0.95 and absf(node.global_position.y - spot.y) < 2.2:
			return true
	return false


func _bot_recover(delta: float) -> void:
	if Match.battle or finished or eliminated or not Match.started:
		return
	if is_on_floor() and global_position.y < checkpoint_pos.y - 3.4:
		_respawn()
		return
	if not bot_marked:
		bot_marked = true
		bot_mark_z = global_position.z
		return
	if wall_running or hanging or zipping or global_position.z < bot_mark_z - 0.45:
		bot_stall = 0.0
		bot_mark_z = global_position.z
		return
	bot_stall += delta
	if bot_stall > 3.4:
		bot_stall = 0.0
		_respawn()


func _floor_ahead() -> bool:
	ahead_ray.force_raycast_update()
	return ahead_ray.is_colliding()


func _bot_prepare() -> void:
	if _bot_set:
		return
	_bot_set = true
	var styles: Array[float] = [0.5, 0.07, 0.94, 0.22, 0.78, 0.38, 0.14, 0.86, 0.58, 0.3]
	var skills: Array[float] = [0.96, 0.86, 0.54, 0.92, 0.64, 0.8, 0.5, 0.74, 0.6, 0.88]
	var i := spawn_slot
	if has_meta("bot_seed"):
		i = int(get_meta("bot_seed"))
	i = posmod(i, styles.size())
	bot_style = styles[i]
	bot_skill = skills[i]
	if view_player:
		bot_style = 0.5
		bot_skill = 0.96
	bot_speed = lerpf(8.05, 9.2, bot_skill)
	_bot_rng.seed = int(spawn_slot) * 9176 + 13


func catch_zip(from: Vector3, to: Vector3) -> void:
	if zipping or hanging or wall_running or finished or stunned > 0.0:
		return
	var span_v := to - from
	var span := span_v.length()
	if span < 1.0:
		return
	var dir := span_v / span
	var along := clampf((global_position - from).dot(dir), 0.0, span)
	var above := (from + dir * along).y - global_position.y
	# A cable at chest or head height catches a run. Higher ones still need a jump.
	if is_on_floor():
		if above < 0.85 or above > 1.95:
			return
	elif above < 0.4 or above > 2.45:
		return
	zipping = true
	zip_from = from
	zip_to = to
	zip_along = clampf((global_position - from).dot(dir), 0.0, span - 0.35)
	sliding = false
	velocity = Vector3.ZERO


func _ride_zip(delta: float, hop: bool) -> void:
	var span_v := zip_to - zip_from
	var span := span_v.length()
	if span < 0.2:
		zipping = false
		return
	var dir := span_v / span
	zip_along += 15.5 * delta
	if hop or zip_along >= span - 0.35:
		zipping = false
		var kick := 6.4 if hop else 2.4
		velocity = dir * 12.0 + Vector3.UP * kick
		jump_buffer = 0.0
		return
	global_position = zip_from + dir * zip_along - Vector3.UP * 1.55
	velocity = dir * 15.5


func _gate_ahead() -> bool:
	block_ray.force_raycast_update()
	if not block_ray.is_colliding():
		return false
	var normal: Vector3 = block_ray.get_collision_normal()
	if normal.dot(Vector3(0, 0, 1)) < 0.5:
		return false
	var body := block_ray.get_collider()
	if body == null or not ("lowered" in body):
		return false
	var point: Vector3 = block_ray.get_collision_point()
	return global_position.z - point.z < 8.0


func _hazard_side() -> int:
	duct_ray.force_raycast_update()
	if not duct_ray.is_colliding():
		return 0
	var body := duct_ray.get_collider()
	if body == null or body.get_script() == null:
		return 0
	var path := str(body.get_script().resource_path)
	if not ("hammer" in path or "saw" in path or "mill" in path):
		return 0
	var point: Vector3 = duct_ray.get_collision_point()
	if point.x >= global_position.x:
		return -1
	return 1


func _bot_wish(delta: float) -> Vector3:
	_bot_prepare()
	var wire := _zip_line()
	var target_x := global_position.x
	if wire < 900.0:
		target_x = wire
	else:
		target_x = _bot_target_x(delta)
		if _gate_ahead():
			target_x = lerpf(global_position.x, 0.0, 0.8)
		else:
			var dodge := _hazard_side()
			if dodge != 0:
				target_x = global_position.x + float(dodge) * lerpf(1.4, 1.95, bot_skill)
			else:
				var pad_x := _boost_x()
				if absf(pad_x - target_x) < 2.6 and _floor_at(pad_x - global_position.x, -3.2):
					target_x = lerpf(target_x, pad_x, lerpf(0.22, 0.8, bot_skill))
				var nudge := _crowd_nudge()
				if absf(nudge) > 0.04 and _floor_at(target_x + nudge - global_position.x, -2.4):
					target_x += nudge
	if is_on_floor():
		target_x -= clampf(velocity.x, -5.0, 5.0) * 0.28
	# Over a real pit, keep the jump arc so a wall kick still reaches the far wall.
	# Over a drop or gap, steer onto the landing that _bot_target_x can see.
	if not is_on_floor() and not wall_running and not zipping and not _bot_saw_floor:
		target_x = global_position.x + velocity.x * 0.45
	var dir := Vector3(target_x - global_position.x, 0, -1)
	if dir.length() < 0.05:
		return Vector3(0, 0, -1)
	return dir.normalized()


func _hole_at(dist: float) -> bool:
	pit_ray.position = Vector3(0, 1.1, -dist)
	pit_ray.target_position = Vector3(0, -2.4, 0)
	pit_ray.force_raycast_update()
	return not pit_ray.is_colliding()


func _floor_sample(x_off: float, z_off: float) -> float:
	# Stay under the slide duct (its soffit is about 1.1) so the ray does not start inside that bar.
	# 13.5m reaches drop landings 4.5–6m down, and a true pit still reads as empty.
	pit_ray.position = Vector3(x_off, 0.95, z_off)
	pit_ray.target_position = Vector3(0, -22.0, 0)
	pit_ray.force_raycast_update()
	if not pit_ray.is_colliding():
		return -999.0
	if pit_ray.get_collision_normal().y <= 0.45:
		return -999.0
	var hit_y := pit_ray.get_collision_point().y
	if hit_y > global_position.y + 1.8 or hit_y < global_position.y - 20.0:
		return -999.0
	return hit_y


func _floor_at(x_off: float, z_off: float) -> bool:
	return _floor_sample(x_off, z_off) > -900.0


func _bot_target_x(delta: float) -> float:
	var hits: Array[Dictionary] = []
	for offset in [-6.4, -4.6, -3.0, -1.6, -0.55, 0.45, 1.5, 2.9, 4.5, 6.3]:
		var x_off := float(offset) + (bot_style - 0.5) * 0.28
		var near := _floor_sample(x_off, -2.4)
		var mid := _floor_sample(x_off, -5.8)
		if near < -900.0 and mid < -900.0:
			continue
		var y := near if near > -900.0 else mid
		var far := _floor_sample(x_off, -9.2)
		var score := 0.0
		if far > -900.0:
			score += lerpf(0.35, 1.7, bot_skill)
			score -= maxf(0.0, global_position.y - far - 1.1) * 0.22
		elif bot_skill > 0.72:
			score -= 0.85
		score -= maxf(0.0, global_position.y - y - 0.55) * 0.5
		if y > global_position.y + 0.4:
			score -= 0.3
		var home := (bot_style - 0.5) * 5.0
		score -= absf(x_off - home) * lerpf(0.18, 0.04, bot_skill)
		hits.append({"x": global_position.x + x_off, "score": score})
	_bot_saw_floor = not hits.is_empty()
	if hits.is_empty():
		return _bot_wall_x()
	hits.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["x"]) < float(b["x"]))
	var lanes: Array[Dictionary] = []
	for hit in hits:
		var x := float(hit["x"])
		if lanes.is_empty() or x - float(lanes.back()["max"]) > 2.05:
			lanes.append({"min": x, "max": x, "sum": x, "n": 1, "score": float(hit["score"])})
		else:
			var lane: Dictionary = lanes.back()
			lane["max"] = x
			lane["sum"] = float(lane["sum"]) + x
			lane["n"] = int(lane["n"]) + 1
			lane["score"] = float(lane["score"]) + float(hit["score"])
	if bot_lane_time > 0.0:
		var held := _lane_near(lanes, bot_lane_x, 1.8)
		if held >= 0 and not _lane_is_worse(lanes, held):
			bot_lane_time = maxf(0.0, bot_lane_time - delta)
			return _bot_place(lanes[held])
		bot_lane_time = 0.0
	var pick := _best_lane(lanes)
	if lanes.size() > 1 and bot_skill < 0.68 and _bot_rng.randf() < 0.4:
		pick = clampi(int(round(bot_style * float(lanes.size() - 1))), 0, lanes.size() - 1)
		if bot_skill < 0.48 and _bot_rng.randf() < 0.35:
			pick = _thinnest_lane(lanes)
	bot_lane_time = lerpf(1.5, 2.5, bot_skill)
	return _bot_place(lanes[pick])


func _lane_near(lanes: Array[Dictionary], x: float, limit: float) -> int:
	var best_i := -1
	var best_d := limit
	for i in lanes.size():
		var mid := float(lanes[i]["sum"]) / float(lanes[i]["n"])
		var dist := absf(mid - x)
		if dist < best_d:
			best_d = dist
			best_i = i
	return best_i


func _lane_score(lane: Dictionary) -> float:
	return float(lane["score"]) / float(lane["n"])


func _best_lane(lanes: Array[Dictionary]) -> int:
	var pick := 0
	var best := -999.0
	for i in lanes.size():
		var score := _lane_score(lanes[i])
		if score > best:
			best = score
			pick = i
	return pick


func _lane_is_worse(lanes: Array[Dictionary], held: int) -> bool:
	if bot_skill < 0.78:
		return false
	var here := _lane_score(lanes[held])
	for i in lanes.size():
		if i != held and _lane_score(lanes[i]) > here + 1.05:
			return true
	return false


func _thinnest_lane(lanes: Array[Dictionary]) -> int:
	var thin := 0
	var thin_n := 999
	for i in lanes.size():
		var n := int(lanes[i]["n"])
		if n < thin_n:
			thin_n = n
			thin = i
	return thin


func _boost_x() -> float:
	if bot_skill < 0.34:
		return global_position.x + 99.0
	var best_x := global_position.x
	var best_d := 12.0
	var found := false
	for node in get_tree().get_nodes_in_group("boost"):
		if not is_instance_valid(node) or not (node is Node3D):
			continue
		var pos := (node as Node3D).global_position
		var ahead := global_position.z - pos.z
		if ahead < 0.5 or ahead > 11.5:
			continue
		if absf(pos.y - global_position.y) > 1.7:
			continue
		if absf(pos.x - global_position.x) > 3.3:
			continue
		if ahead < best_d:
			best_d = ahead
			best_x = pos.x
			found = true
	if not found:
		return global_position.x + 99.0
	return best_x


func _crowd_nudge() -> float:
	var nudge := 0.0
	for node in get_tree().get_nodes_in_group("runners"):
		if node == self or not (node is Node3D):
			continue
		var other: Node3D = node as Node3D
		var ahead := global_position.z - other.global_position.z
		if ahead < 0.15 or ahead > 2.15:
			continue
		var dx := other.global_position.x - global_position.x
		if absf(dx) > 0.9:
			continue
		var side := -1.0 if dx > 0.02 else 1.0
		if absf(dx) <= 0.02:
			side = -1.0 if bot_style < 0.5 else 1.0
		nudge += side * lerpf(0.4, 0.9, bot_skill)
	return clampf(nudge, -1.25, 1.25)


func _zip_line() -> float:
	var best_d := 5.5
	var best_x := 0.0
	var found := false
	var here := global_position
	for node in get_tree().get_nodes_in_group("zip"):
		var line := node as Node3D
		if line == null:
			continue
		var from := line.get("a") as Vector3
		var to := line.get("b") as Vector3
		if from.distance_squared_to(to) < 1.0:
			continue
		if here.z < to.z + 1.2:
			continue
		if here.z > from.z + 11.0:
			continue
		var dx := absf(from.x - here.x)
		if dx < best_d:
			best_d = dx
			best_x = from.x
			found = true
	if not found:
		return 999.0
	return best_x


func _bot_place(lane: Dictionary) -> float:
	var mid := float(lane["sum"]) / float(lane["n"])
	bot_lane_x = mid
	var half := maxf(0.0, (float(lane["max"]) - float(lane["min"])) * 0.5)
	var room := maxf(0.0, half - 0.42)
	var spread := lerpf(0.85, 0.4, bot_skill)
	var shift := clampf((bot_style - 0.5) * 2.0 * spread, -room, room)
	return mid + shift


func _bot_wall_x() -> float:
	var best_d := 999.0
	var best_x := global_position.x
	var found := false
	for ray: RayCast3D in [sense_l, sense_r]:
		ray.force_raycast_update()
		if not ray.is_colliding():
			continue
		var normal: Vector3 = ray.get_collision_normal()
		if absf(normal.y) > 0.4:
			continue
		var point := ray.get_collision_point()
		var dist := absf(point.x - global_position.x)
		if dist < best_d:
			best_d = dist
			best_x = point.x + normal.x * (RADIUS + 0.12)
			found = true
	if not found:
		return global_position.x
	return best_x


func _blocked_ahead() -> bool:
	block_ray.force_raycast_update()
	if not block_ray.is_colliding():
		return false
	var normal: Vector3 = block_ray.get_collision_normal()
	return normal.dot(Vector3(0, 0, 1)) > 0.55


func _rise_ahead() -> bool:
	rise_ray.force_raycast_update()
	if not rise_ray.is_colliding():
		return false
	var normal: Vector3 = rise_ray.get_collision_normal()
	if normal.dot(Vector3(0, 0, 1)) < 0.55:
		return false
	var point := rise_ray.get_collision_point()
	var ahead := global_position.z - point.z
	# Kick late enough to clear the lip, early enough to still be on the wall.
	if ahead < 3.3 or ahead > 4.8:
		return false
	return point.y > global_position.y + 0.45


func _bot_wants_jump(delta: float) -> bool:
	if zipping or hanging:
		return false
	if _zip_line() < 900.0:
		return false
	if _gate_ahead():
		return false
	if wall_running and wall_time > 0.16 and (_floor_at(0.0, -3.4) or _floor_at(wall_normal.x * 1.4, -3.6)):
		bot_jump_wait = 0.0
		return true
	if wall_running and wall_time > 0.18 and _rise_ahead():
		bot_jump_wait = 0.0
		return true
	if wall_running and wall_time > 0.28:
		bot_jump_wait = 0.0
		var other: RayCast3D = sense_r if wall_side < 0 else sense_l
		other.force_raycast_update()
		if other.is_colliding():
			var normal: Vector3 = other.get_collision_normal()
			if absf(normal.y) < 0.4 and normal.dot(wall_normal) < 0.15:
				return true
		return false
	if is_on_floor() and horizontal_speed() > 2.4 and _blocked_ahead() and not _bot_wants_slide():
		bot_jump_wait = 0.0
		return true
	if is_on_floor() and horizontal_speed() > 5.2:
		var near_y := _floor_sample(0.0, -0.55)
		var step_y := _floor_sample(0.0, -1.45)
		if near_y > -900.0 and absf(near_y - global_position.y) < 0.22:
			if step_y > global_position.y + 0.5 and step_y < global_position.y + 1.15:
				bot_jump_wait = 0.0
				return true
	if is_on_floor() and horizontal_speed() > 4.5:
		var lip := not _floor_at(0.0, -1.05)
		var coming := not _floor_at(0.0, -lerpf(1.45, 2.35, bot_skill))
		if coming and not bot_gap_set:
			bot_gap_set = true
			bot_gap_late = bot_skill < 0.62 and _bot_rng.randf() > bot_skill
		if lip:
			bot_jump_wait += delta
			var late := 0.1 if bot_gap_late else 0.0
			return bot_jump_wait >= late
		if coming:
			return false
	bot_jump_wait = 0.0
	bot_gap_set = false
	return false


func _bot_wants_slide() -> bool:
	if _gate_ahead():
		return false
	duct_ray.force_raycast_update()
	if duct_ray.is_colliding():
		return true
	ceil_ray.force_raycast_update()
	return ceil_ray.is_colliding()


func _animate_hands(delta: float) -> void:
	var spd := horizontal_speed()
	var swing := sin(run_cycle)
	var l_pos := Vector3(-0.34, -0.4, -0.5)
	var r_pos := Vector3(0.34, -0.4, -0.5)
	var l_rot := Vector3(swing * 0.55, 0, 0.05)
	var r_rot := Vector3(-swing * 0.55, 0, -0.05)
	if hanging:
		var planted := -0.08 if mantling else -0.28
		l_pos = Vector3(-0.16, planted, -0.78)
		r_pos = Vector3(0.16, planted, -0.78)
		l_rot = Vector3(-0.55, 0.2, 0.15)
		r_rot = Vector3(-0.55, -0.2, -0.15)
	elif sliding:
		l_pos = Vector3(-0.52, -0.34, -0.42)
		r_pos = Vector3(0.46, -0.3, -0.28)
		l_rot = Vector3(0.35, 0.7, 1.15)
		r_rot = Vector3(0.55, -0.35, -0.85)
	elif wall_running:
		var scrape := sin(run_cycle * 2.2) * 0.035
		if wall_side < 0:
			l_pos = Vector3(-0.62, -0.08, -0.4 + scrape)
			l_rot = Vector3(0.15, 0.35, 1.05)
			r_pos = Vector3(0.2, -0.36, -0.32)
			r_rot = Vector3(0.7, 0, -0.25)
		else:
			r_pos = Vector3(0.62, -0.08, -0.4 + scrape)
			r_rot = Vector3(0.15, -0.35, -1.05)
			l_pos = Vector3(-0.2, -0.36, -0.32)
			l_rot = Vector3(0.7, 0, 0.25)
	elif spd > 2.0 and is_on_floor():
		l_pos += Vector3(0, swing * 0.08, cos(run_cycle) * 0.16)
		r_pos += Vector3(0, -swing * 0.08, cos(run_cycle + PI) * 0.16)
	var blend := 1.0 - exp(-12.0 * delta)
	left_hand.position = left_hand.position.lerp(l_pos, blend)
	right_hand.position = right_hand.position.lerp(r_pos, blend)
	left_hand.rotation.x = lerp_angle(left_hand.rotation.x, l_rot.x, blend)
	left_hand.rotation.y = lerp_angle(left_hand.rotation.y, l_rot.y, blend)
	left_hand.rotation.z = lerp_angle(left_hand.rotation.z, l_rot.z, blend)
	right_hand.rotation.x = lerp_angle(right_hand.rotation.x, r_rot.x, blend)
	right_hand.rotation.y = lerp_angle(right_hand.rotation.y, r_rot.y, blend)
	right_hand.rotation.z = lerp_angle(right_hand.rotation.z, r_rot.z, blend)


func _sync_net() -> void:
	if multiplayer.multiplayer_peer == null:
		return
	var emote_i := Emotes.index_of(emote)
	_state.rpc(global_position, rotation.y, pitch, wall_side, sliding, finished, race_time, emote_i)


@rpc("authority", "unreliable_ordered", "call_remote")
func _state(pos: Vector3, pyaw: float, ppitch: float, side: int, slide: bool, done: bool, clock: float, emote_i: int) -> void:
	net_pos = pos
	net_yaw = pyaw
	net_pitch = ppitch
	wall_side = side
	wall_running = side != 0
	sliding = slide
	has_net = true
	emote = Emotes.id_for(emote_i)
	race_time = clock
	if done:
		if not finished:
			finished = true
			_drop_body_block()
			var race := get_tree().get_first_node_in_group("race")
			if race != null and race.has_method("runner_finished"):
				race.runner_finished(self)
		elif collision_layer != 0:
			_drop_body_block()
