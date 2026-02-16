extends Control

const CARD = preload("uid://fthm33kvreby")

@export_enum("player", "npc") var deck_owner = 0

@export var deck: Array[Vector3]

func spawn_deck():
	for n in deck:
		var c = CARD.instantiate()
		add_child(c)
		c.suit = n.x
		c.value = n.y
		c.image = n.z
		c.get_child(1).texture = Settings.images[n.z]
	
	shuffle()

func use_top_card() -> Vector3:
	return Vector3(get_child(0).suit, get_child(0).value, get_child(0).image)
	Settings.card_turn = not Settings.card_turn

func shuffle():
	for n in get_children():
		move_child(n, randi_range(0, get_child_count()))
