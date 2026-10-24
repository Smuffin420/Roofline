extends Node

var map_id := "annex"
var audit := false
var started := false
var granted := false
var results: Array = []
var your_place := 10
var your_finished := false
var your_falls := 0
var your_time := 0.0
var field_size := 10
var practice := false
var challenge := false
var speedrun := false
var battle := false
var picking_battle := false
var fill_bots := false
var lobby_bots := true
var previous_pb := -1.0
var beat_pb := false
var pb_time := -1.0
var series := false
var round_index := 0
var played: Array[String] = []
var qualifiers: Array = []
var through := true
var ran := false
var advanced := false
var cut_for := -1


func begin_race(id: String) -> void:
	map_id = id
	started = false
	granted = false
	practice = false
	challenge = false
	speedrun = false
	battle = false
	picking_battle = false
	fill_bots = false
	previous_pb = -1.0
	beat_pb = false
	pb_time = -1.0
	results = []
	your_place = 10
	your_finished = false
	your_falls = 0
	your_time = 0.0
	ran = false
	field_size = round_size() if series else 10


func open_series() -> void:
	series = true
	round_index = 0
	played.clear()
	qualifiers.clear()
	through = true
	ran = false
	advanced = false
	cut_for = -1


func clear_series() -> void:
	series = false
	round_index = 0
	played.clear()
	qualifiers.clear()
	through = true
	ran = false
	advanced = false
	cut_for = -1


func note_played(id: String) -> void:
	if id != "" and not played.has(id):
		played.append(id)


func round_size() -> int:
	match round_index:
		0:
			return 20
		1:
			return 10
		_:
			return 5


func cut_line() -> int:
	match round_index:
		0:
			return 10
		1:
			return 5
		_:
			return 1


func on_final() -> bool:
	return series and round_index >= 2


func round_heading() -> String:
	match round_index:
		0:
			return "Round 1 of 3. Twenty runners."
		1:
			return "Round 2 of 3. Ten runners."
		_:
			return "The final. Five runners."


func short_round() -> String:
	match round_index:
		0:
			return "Round 1"
		1:
			return "Round 2"
		_:
			return "Final"


func fresh(id: String) -> bool:
	return not series or not played.has(id)


func is_me(row: Dictionary) -> bool:
	var id := str(row["id"])
	if Network.is_online():
		return id.is_valid_int() and int(id) == multiplayer.get_unique_id()
	return id == "you"


func keep(rows: Array, force: bool = false) -> void:
	if not series:
		return
	if cut_for == round_index and not force:
		return
	cut_for = round_index
	qualifiers = []
	through = false
	var keep_n := mini(cut_line(), rows.size())
	for i in keep_n:
		var src: Dictionary = rows[i]
		qualifiers.append({
			"id": str(src["id"]),
			"name": str(src["name"]),
			"bot": bool(src["bot"]),
			"color": str(src["color"]),
			"hat": str(src["hat"]),
			"style": str(src["style"]),
			"trail": str(src["trail"]),
			"seed": int(src["seed"]),
		})
		if is_me(src):
			through = true
	advanced = false


func begin_battle(id: String = "annex") -> void:
	begin_race(id)
	battle = true
	fill_bots = true
	picking_battle = false
	field_size = 10
