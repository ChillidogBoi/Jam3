extends Control

var direction: String

func _ready():
	$TextureRect.texture = $TextureRect.texture.duplicate()


func _process(delta):
	position.x += delta * 600
	if position.x > 1300:
		queue_free()
