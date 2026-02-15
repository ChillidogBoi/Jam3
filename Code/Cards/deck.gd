extends Control



func _on_gui_input(event):

func use_top_card()
	if Settings.card_turn != 0: return
	Settings.next_card_turn() = 
