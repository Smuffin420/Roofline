extends RefCounted

# Personal bests live in user://ghosts/<map>.bin. A run is a clock time
# plus samples of where the runner was, so the next speedrun can play it back.

const STRIDE := 5
const MAGIC := 0x47535431
const SNAP := 12.0


static func format_clock(seconds: float) -> String:
	var m := int(seconds) / 60
	var s := seconds - float(m * 60)
	return "%d:%05.2f" % [m, s]


static func best_time(map_id: String) -> float:
	var run := load_run(map_id)
	if run.is_empty():
		return -1.0
	return float(run["time"])


static func load_run(map_id: String) -> Dictionary:
	var path := _path(map_id)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	if file.get_32() != MAGIC:
		return {}
	var time := file.get_float()
	var count := int(file.get_32())
	if count <= 0 or count > 40000:
		return {}
	var samples := file.get_buffer(count * STRIDE * 4).to_float32_array()
	if samples.size() != count * STRIDE or time <= 0.0:
		return {}
	return {"time": time, "samples": samples}


static func save_run(map_id: String, time: float, samples: PackedFloat32Array) -> bool:
	if time <= 0.0 or samples.size() < STRIDE or samples.size() % STRIDE != 0:
		return false
	DirAccess.make_dir_recursive_absolute("user://ghosts")
	var file := FileAccess.open(_path(map_id), FileAccess.WRITE)
	if file == null:
		return false
	file.store_32(MAGIC)
	file.store_float(time)
	file.store_32(samples.size() / STRIDE)
	file.store_buffer(samples.to_byte_array())
	return true


static func pose_at(samples: PackedFloat32Array, t: float) -> Dictionary:
	var count := samples.size() / STRIDE
	if count <= 0:
		return {"ok": false, "pos": Vector3.ZERO, "yaw": 0.0}
	if t <= samples[0]:
		return _frame(samples, 0)
	var last := count - 1
	if t >= samples[last * STRIDE]:
		return _frame(samples, last)
	var lo := 0
	var hi := last
	while lo + 1 < hi:
		var mid := (lo + hi) >> 1
		if samples[mid * STRIDE] <= t:
			lo = mid
		else:
			hi = mid
	var t0 := samples[lo * STRIDE]
	var t1 := samples[hi * STRIDE]
	var a := _frame(samples, lo)
	var b := _frame(samples, hi)
	var p0: Vector3 = a["pos"]
	var p1: Vector3 = b["pos"]
	if p0.distance_to(p1) > SNAP:
		return a
	var u := 0.0
	if t1 > t0:
		u = clampf((t - t0) / (t1 - t0), 0.0, 1.0)
	return {
		"ok": true,
		"pos": p0.lerp(p1, u),
		"yaw": lerp_angle(float(a["yaw"]), float(b["yaw"]), u),
	}


static func _frame(samples: PackedFloat32Array, index: int) -> Dictionary:
	var i := index * STRIDE
	return {
		"ok": true,
		"pos": Vector3(samples[i + 1], samples[i + 2], samples[i + 3]),
		"yaw": samples[i + 4],
	}


static func _path(map_id: String) -> String:
	var clean := ""
	for i in map_id.length():
		var c := map_id.substr(i, 1)
		var code := c.unicode_at(0)
		var ok := (code >= 97 and code <= 122) or (code >= 48 and code <= 57)
		if ok:
			clean += c
	if clean.is_empty():
		clean = "roof"
	return "user://ghosts/%s.bin" % clean
