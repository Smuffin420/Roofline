extends Node

# Foley is CC0 from Kenney (kenney.nl).

const _FILES := {
	"step": ["res://audio/step0.ogg", "res://audio/step1.ogg", "res://audio/step2.ogg"],
	"snow": ["res://audio/snow0.ogg", "res://audio/snow1.ogg"],
	"land": ["res://audio/land0.ogg", "res://audio/land1.ogg"],
	"jump": ["res://audio/jump0.ogg", "res://audio/jump1.ogg"],
	"boost": ["res://audio/boost0.ogg", "res://audio/boost1.ogg"],
	"vent": ["res://audio/vent.ogg"],
	"hit": ["res://audio/hit0.ogg", "res://audio/hit1.ogg"],
	"wall": ["res://audio/wall.ogg"],
	"grab": ["res://audio/grab.ogg"],
	"check": ["res://audio/check.ogg"],
	"finish": ["res://audio/finish.ogg"],
	"click": ["res://audio/click0.ogg", "res://audio/click1.ogg"],
}

var _bank := {}
var _pool: Array[AudioStreamPlayer] = []
var _token: Array[int] = []
var _slot := 0
var _slide_player: AudioStreamPlayer
var _slide_active := false
var _slide_goal := -80.0


func _ready() -> void:
	for _i in 12:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_pool.append(player)
		_token.append(0)
	for id in _FILES:
		var streams: Array[AudioStream] = []
		for path in _FILES[id]:
			var stream := load(path) as AudioStream
			if stream != null:
				streams.append(stream)
		_bank[id] = streams
	_bank["slide"] = [_whoosh(false)]
	_bank["spring"] = [_boing()]
	_bank["tick"] = [_tone(740.0, 0.06, 0.22)]
	_bank["horn"] = [_tone(1180.0, 0.14, 0.42)]
	_slide_player = AudioStreamPlayer.new()
	_slide_player.stream = _whoosh(true)
	_slide_player.volume_db = -80.0
	add_child(_slide_player)


func _process(delta: float) -> void:
	if _slide_player == null or not _slide_player.playing:
		return
	_slide_player.volume_db = move_toward(_slide_player.volume_db, _slide_goal, delta * 160.0)
	if not _slide_active and _slide_player.volume_db <= -45.0:
		_slide_player.stop()


func play(id: String, volume_db: float = 0.0, pitch: float = 1.0, cutoff: float = -1.0) -> void:
	var streams: Array = _bank.get(id, [])
	if streams.is_empty() or _pool.is_empty():
		return
	if id == "slide" and cutoff < 0.0:
		cutoff = 0.4
	var index := _slot
	var player := _pool[index]
	_slot = (_slot + 1) % _pool.size()
	_token[index] += 1
	var token := _token[index]
	var kind := "ui" if id == "click" else "effects"
	player.stream = streams[randi() % streams.size()]
	player.volume_db = volume_db + Settings.gain(kind)
	player.pitch_scale = pitch * randf_range(0.96, 1.04)
	player.play()
	if cutoff > 0.0:
		_cut(player, index, token, cutoff, player.volume_db)


func slide(active: bool, speed: float) -> void:
	if _slide_player == null:
		return
	_slide_active = active
	if not active:
		_slide_goal = -80.0
		return
	var loud := lerpf(-18.0, -8.0, clampf((speed - 2.5) / 12.0, 0.0, 1.0))
	_slide_goal = loud + Settings.gain("effects")
	_slide_player.pitch_scale = lerpf(0.88, 1.12, clampf(speed / 16.0, 0.0, 1.0))
	if not _slide_player.playing:
		_slide_player.volume_db = _slide_goal
		_slide_player.play()


func _cut(player: AudioStreamPlayer, index: int, token: int, hold: float, loud: float) -> void:
	await get_tree().create_timer(hold).timeout
	if index >= _token.size() or _token[index] != token:
		return
	var age := 0.0
	while age < 0.08:
		if _token[index] != token:
			return
		age += get_process_delta_time()
		player.volume_db = lerpf(loud, loud - 28.0, clampf(age / 0.08, 0.0, 1.0))
		await get_tree().process_frame
	if _token[index] == token:
		player.stop()


func _whoosh(looping: bool) -> AudioStreamWAV:
	var rate := 22050
	var count := rate
	var blend := int(float(rate) * 0.06)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5280
	var low := 0.0
	var mid := 0.0
	for i in count:
		var phase := float(i) / float(rate)
		var cut := 0.05 + 0.028 * sin(phase * TAU * 0.65)
		var white := rng.randf_range(-1.0, 1.0)
		low += (white - low) * cut
		mid += (white - mid) * cut * 3.1
		var breathe := 0.86 + 0.14 * sin(phase * TAU * 1.4)
		samples[i] = (low * 0.82 + mid * 0.2) * breathe
	var out_count := count
	if looping:
		out_count = count - blend
		for i in blend:
			var t := float(i) / float(blend)
			samples[i] = lerpf(samples[count - blend + i], samples[i], t)
	if not looping:
		var edge := int(float(rate) * 0.02)
		for i in out_count:
			var fade := 1.0
			if i < edge:
				fade = float(i) / float(edge)
			elif i > out_count - edge:
				fade = float(out_count - i) / float(edge)
			samples[i] *= fade
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	if looping:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = out_count
	var data := PackedByteArray()
	data.resize(out_count * 2)
	for i in out_count:
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 26000.0))
	wav.data = data
	return wav


func _tone(freq: float, length: float, amp: float) -> AudioStreamWAV:
	var rate := 22050
	var count := int(float(rate) * length)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var phase := 0.0
	for i in count:
		var k := float(i) / float(count)
		var env := sin(k * PI)
		env = env * env
		phase += TAU * freq / float(rate)
		samples[i] = sin(phase) * env * amp
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 27000.0))
	wav.data = data
	return wav


func _boing() -> AudioStreamWAV:
	# Three coil bounces. Each one starts at a pitch and falls, like a spring letting go.
	var rate := 22050
	var length := 0.64
	var count := int(float(rate) * length)
	var samples := PackedFloat32Array()
	samples.resize(count)
	var bounces := [
		{"at": 0.0, "len": 0.22, "from": 420.0, "to": 150.0, "amp": 0.88},
		{"at": 0.24, "len": 0.16, "from": 300.0, "to": 125.0, "amp": 0.46},
		{"at": 0.42, "len": 0.14, "from": 230.0, "to": 105.0, "amp": 0.22},
	]
	var phase := PackedFloat32Array()
	phase.resize(bounces.size())
	for i in count:
		var t := float(i) / float(rate)
		var sample := 0.0
		for b in bounces.size():
			var spec: Dictionary = bounces[b]
			var u := t - float(spec["at"])
			var span := float(spec["len"])
			if u < 0.0 or u > span:
				continue
			var k := u / span
			var freq := lerpf(float(spec["from"]), float(spec["to"]), k * k)
			phase[b] += TAU * freq / float(rate)
			var env := sin(k * PI)
			var tone := sin(phase[b]) * 0.78 + sin(phase[b] * 2.03) * 0.18
			sample += tone * env * float(spec["amp"])
		samples[i] = clampf(sample, -1.0, 1.0)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		data.encode_s16(i * 2, int(samples[i] * 27000.0))
	wav.data = data
	return wav
