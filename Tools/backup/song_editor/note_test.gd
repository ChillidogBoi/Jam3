extends Control

var direction: String

func _process(delta):
	position.x += delta * 300
	if position.x > 1020:
		queue_free()
