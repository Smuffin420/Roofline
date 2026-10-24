extends RefCounted

# One held item at a time. The crate rolls these evenly so a short match shows each one.
const ALL := ["dash", "brick", "slick", "guard", "gust"]


static func all() -> Array:
	return ALL


static func roll(rng: RandomNumberGenerator) -> String:
	return ALL[rng.randi() % ALL.size()]


static func label_of(id: String) -> String:
	match id:
		"dash":
			return "Dash"
		"brick":
			return "Brick"
		"slick":
			return "Slick"
		"guard":
			return "Guard"
		"gust":
			return "Gust"
		_:
			return ""
