extends Label


func _on_visibility_changed():
	await get_tree().create_timer(0.25).timeout
	visible = false
