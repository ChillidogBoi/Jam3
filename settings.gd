extends Node

#rythm
var current_song

#cards
const images = [preload("res://Art/Developer/card_face.png"),]
var card_turn
var your_card: Vector3 = Vector3.ZERO
var npc_card: Vector3 = Vector3.ZERO
var card_tutorial_done = false
