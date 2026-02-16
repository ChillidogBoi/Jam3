extends Control

@export var image: int
@export var value: int
@export_enum("Buy -> Get", "% Off", "$ Off", "Voucher") var suit: int

## for side: 0 is back, 1 is front and 2 is the opposite of the current side
func flip_card(side:int = 2):
	match side:
		2: move_child(get_child(1),0)
		1: move_child(find_child("front"), 0)
		0: move_child(find_child("back"), 0)
