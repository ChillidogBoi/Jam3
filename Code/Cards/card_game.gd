extends Control


func _ready():
	if not Settings.card_tutorial_done: await tutorial()
	var result = await main_loop()
	

func main_loop():
	if $Deck.get_child_count() == 0: return 0
	elif $Deck2.get_child_count() == 0: return 1
	
	var npc_card = $Deck2.use_top_card()
	npc_card.flip_card()
	var player_card
	
	main_loop()


func tutorial():
	pass # write me
