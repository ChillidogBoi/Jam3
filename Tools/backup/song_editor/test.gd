extends Control

const NOTE = preload("uid://bgfuwvssv460k")
var current_song: song
var time_elapsed = 0
var notes_sent = 0
var c


func _ready():
	current_song = global.current_song
	$Label.text = current_song.song_name
	$AudioStreamPlayer.stream = current_song.audio_track
	$Label2.text = "3"
	await get_tree().create_timer(1).timeout
	$Label2.text = "2"
	await get_tree().create_timer(1).timeout
	$Label2.text = "1"
	await get_tree().create_timer(1).timeout
	$Label2.text = "Go!"
	$AudioStreamPlayer.play()
	await get_tree().create_timer(0.5).timeout
	$Label2.text = ""

func _process(delta):
	note_creation(delta)
	input_detection(delta)


func note_creation(delta):
	if not current_song.note_list.size() > notes_sent: return
	if current_song.note_list[notes_sent].y <= time_elapsed:
		c = NOTE.instantiate()
		$Note_Control.add_child(c)
		c.get_child(0).rotation = PI/2 * current_song.note_list[notes_sent].x
		match current_song.note_list[notes_sent].x:
			0.0: c.direction = "right"
			1.0: c.direction = "down"
			2.0: c.direction = "left"
			3.0: c.direction = "up"
		notes_sent += 1
	time_elapsed += delta


func input_detection(delta):
	if $Note_Control.get_children() == []: return
	var x = 1000
	var note
	for n in $Note_Control.get_children():
		n.position.y = 40
		if abs($TextureRect.global_position.x - n.global_position.x) < x:
			x = abs($TextureRect.global_position.x - n.global_position.x)
			note = n
	if not note: return
	if $TextureRect.global_position.x - note.global_position.x < -150:
		note.queue_free()
		return
	note.position.y = 0
	$TextureRect/TextureRect.rotation = note.get_child(0).rotation
	if Input.is_action_just_pressed(note.direction):
		if abs($TextureRect.global_position.x - note.global_position.x) < 15:
			$score.text = "Great!"
			$score.visible = true
		elif abs($TextureRect.global_position.x - note.global_position.x) < 30:
			$score.text = "Good!"
			$score.visible = true
		elif abs($TextureRect.global_position.x - note.global_position.x) < 50:
			$score.text = "Okay!"
			$score.visible = true
		else:
			$score.text = "Boo!"
			$score.visible = true
		
		note.queue_free()

func _on_button_pressed():
	get_tree().change_scene_to_file("res://editor.tscn")
