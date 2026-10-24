extends RefCounted

static var LIST: PackedStringArray = PackedStringArray([
	"Roofus", "Gutterball", "Chimney Sue", "Skylark", "Pigeon Toe", "Antenna",
	"Shingles", "Eaves", "Tarfoot", "Weathervane", "Sooty", "Gargoyle",
	"Catwalk", "Penthouse", "Downspout", "Ledge Lord", "Fire Escape", "Brickbat",
	"Roofrat", "Gable", "Dormer", "Skylight", "Cupola", "Parapet",
	"Cornice", "Scupper", "Soffit", "Fascia", "Ridge", "Lookout",
	"Nightowl", "Skyline", "Nimbus", "Zephyr", "Squall", "Updraft",
	"Thermal", "Whoosh", "Swoop", "Glide", "Clatter", "Tumble",
	"Sendy", "Crux", "Flashfoot", "Birdnest", "Coocoo", "Sparrow",
	"Starling", "Magpie", "Kestrel", "Osprey", "Puffin", "Gull",
	"Wren", "Finch", "Swallow", "Swift", "Heron", "Crane",
	"Ibis", "Pelican", "Albatross", "Bootlace", "Loose Tile", "Wet Paint",
	"No Step", "Mind Gap", "Last Step", "Soft Land", "Hard Hat", "Tin Roof",
	"Copper Top", "Slate", "Thatch", "Tar Paper", "Hot Tar", "Cool Roof",
	"Green Roof", "Gold Leaf", "Weathered", "Rusty", "Patina", "Mossback",
	"Ivy", "Tendril", "Trellis", "Pergola", "Gazebo", "Belvedere",
	"Widow Walk", "Crows Nest", "Tip Toe", "Big Step", "Little Hop", "Moonwalk",
	"Sunbake", "Dawn Patrol", "Dusk", "Midnight", "Lunchbreak", "Overtime",
	"Shortcut", "Long Way", "Scenic", "Detour", "Wrong Turn", "U-Turn",
	"Pace Car", "Drafting", "Slipstream", "Tail Wind", "Head Wind", "Crosswind",
	"Gusty", "Breezy", "Blustery", "Howler", "Whistler", "Clickclack",
	"Beep", "Honk", "Toot", "Chirp", "Caw", "Honker",
	"Goose", "Duck", "Swan", "Loon", "Coot", "Plover",
	"Curlew", "Godwit", "Willet", "Stilt", "Turnstone", "Sandpiper",
	"Oystercatch", "Yellowlegs", "Dowitcher", "Avocet", "Snipe", "Rail",
	"Nighthawk", "Whippoor", "Chuckwill", "Poorwill", "Nighthawk Jr", "Barn Owl",
	"Screech", "Snowy", "Barred", "Great Horn", "Elf Owl", "Burrowing",
	"Potoo", "Frogmouth", "Oilbird", "Kiwi", "Kakapo", "Kea",
	"Tui", "Bellbird", "Kokako", "Saddleback", "Stitchbird", "Rifleman",
	"Fantail", "Tomtit", "Robin", "Silvereye", "Waxeye", "Hoiho",
	"Blue Pete", "Red Pete", "Gutter Gus", "Tile Tina", "Vent Vince", "Stack Steve",
	"Cap Cole", "Jack Flash", "Boot Betty", "Sill Sally", "Mullion", "Transom",
	"Awning", "Canopy", "Marquee", "Neon Ned", "Stoop", "Bannister",
	"Newel", "Nosing", "Stringer", "Handrail", "Baluster", "Landing",
	"Riser", "Tread", "Looky", "Peekaboo", "Sneaky", "Almost",
	"Retry", "First Try", "Second Wind", "Third Floor", "Fourth Floor", "Top Floor",
	"Attic", "Loft", "Garret", "Belvedere Jr", "Cupola Kid", "Spire",
	"Steeple", "Belfry", "Bat", "Moth", "Junebug", "Firefly",
	"Lightning", "Thunder", "Drizzle", "Sprinkle", "Downpour", "Puddle",
	"Gutter Gum", "Leaf", "Twig", "Acorn", "Pinecone", "Nest Egg",
	"Two Eggs", "Three Eggs", "Empty Nest", "Full Nest", "Fledgling", "Hatchling",
	"Scoot", "Scramble", "Scamper", "Skitter", "Scurry", "Dash",
	"Bolt", "Flash", "Zippy", "Zoom", "Vroom", "Yeet",
	"Boing", "Sproing", "Whee", "Yahoo", "Geronimo", "Alley Oop",
	"Hotfoot", "Cold Feet", "Happy Feet", "Two Left", "Right Foot", "Both Feet",
	"Kneepads", "Elbows", "Palms", "Fingertips", "Toenails", "Shoelace",
	"Untied", "Double Knot", "Bunny Ear", "Loop", "Hook", "Carabiner",
	"Quickdraw", "Sling", "Anchor", "Bolt Hang", "Hangdog", "Send Train",
	"Pink Point", "Onsight", "Flash It", "Redpoint", "Project", "Wiggly",
	"Greasy", "Chalky", "Dusty", "Smudgy", "Grimy", "Soot Sprite",
	"Chim Chim", "Sweep", "Brush", "Broom", "Mop", "Bucket",
	"Suds", "Rinse", "Drip", "Drop", "Splash", "Splat",
])


static func take(used: Dictionary) -> String:
	var open: PackedStringArray = PackedStringArray()
	for entry in LIST:
		if not used.has(entry):
			open.append(entry)
	if open.is_empty():
		open = LIST
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var pick := open[rng.randi_range(0, open.size() - 1)]
	used[pick] = true
	return pick
