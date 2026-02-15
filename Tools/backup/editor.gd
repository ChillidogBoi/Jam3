extends Control

const NOTE = preload("uid://duopt6ew2xshj")

var dragging = false
var current_song: song
var start_audio_back = false

func _ready():
	if global.current_song:
		current_song = current_song
		if current_song.audio_track:
			$AudioStreamPlayer.stream = current_song.audio_track
			$HSlider.max_value = $AudioStreamPlayer.stream.get_length()
			$HSlider.value = 0.0
			$Label.text = str($HSlider.value, "s / ", $HSlider.max_value,"s")
			$HSlider.editable = true
		for n in current_song.note_list:
			place_note_vis(n.x, n.y)
	if OS.get_name() == "Windows":
		$upload/FileDialog.current_dir = str(OS.get_user_data_dir().get_slice("AppData", 0),"Downloads")
		$save/FileDialog.current_dir = str(OS.get_user_data_dir().get_slice("AppData", 0),"Downloads")
		$upload2/FileDialog.current_dir = str(OS.get_user_data_dir().get_slice("AppData", 0),"Downloads")

func _on_button_pressed():
	$upload/FileDialog.visible = true

func _on_file_dialog_confirmed():
	var new_song: AudioStream
	print($upload/FileDialog.current_path)
	match $upload/FileDialog.current_path.get_slice(".", 1).to_lower():
		"ogg": new_song = AudioStreamOggVorbis.load_from_file($upload/FileDialog.current_path)
		"mp3": new_song = AudioStreamMP3.load_from_file($upload/FileDialog.current_path)
		"wav": new_song = AudioStreamWAV.load_from_file($upload/FileDialog.current_path)
	if new_song == null: return
	$AudioStreamPlayer.stream = new_song
	$HSlider.max_value = $AudioStreamPlayer.stream.get_length()
	$HSlider.value = 0.0
	$Label.text = str($HSlider.value, "s / ", $HSlider.max_value,"s")
	$HSlider.editable = true
	if current_song: current_song.audio_track = new_song

func _on_h_slider_value_changed(value):
	$Label.text = str($HSlider.value, "s / ", $HSlider.max_value,"s")
	$Panel/ColorRect.position.x = (($HSlider.value/$HSlider.max_value) * $Panel.size.x)

func _on_play_pressed():
	if not $AudioStreamPlayer.playing: $AudioStreamPlayer.play($HSlider.value)
	else: $AudioStreamPlayer.stop()

func _process(delta):
	if not $AudioStreamPlayer.playing:
		if start_audio_back:
			$AudioStreamPlayer.play($HSlider.value)
			start_audio_back = false
		else: return
	if dragging: return
	$HSlider.value = $AudioStreamPlayer.get_playback_position()

func _on_h_slider_drag_ended(value_changed):
	dragging = false
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
		start_audio_back = true
func _on_h_slider_drag_started():
	dragging = true

func _on_line_edit_text_changed(new_text):
	if current_song: current_song.song_name = new_text

func _on_add_note_pressed():
	if not current_song: return
	place_note_vis($add_note/Button.selected, $HSlider.value)
	current_song.note_list.append(Vector2($add_note/Button.selected, $HSlider.value))
	current_song.note_list.sort_custom(func(a, b): return a.y < b.y)

func place_note_vis(type:int, time:float):
	var c = NOTE.instantiate()
	$Panel.add_child(c)
	c.rotation = PI/2 * type
	c.position.y = 40
	c.position.x = ((time/$HSlider.max_value) * $Panel.size.x) - $Panel.position.x/2
	c.pressed.connect(erase_note.bind(c, time))

func erase_note(note: TextureButton, time: float):
	for n in current_song.note_list:
		if n.y == time: current_song.note_list.erase(n)
	note.queue_free()

func _on_new_song_pressed():
	for n in $Panel.get_children():
		if n != $Panel/ColorRect: n.queue_free()
	current_song = song.new()
	if $AudioStreamPlayer.stream: current_song.audio_track = $AudioStreamPlayer.stream
	$LineEdit.text = current_song.song_name
	$LineEdit.editable = true

func _on_save_pressed():
	if not current_song: return
	$save/FileDialog.current_file = str($LineEdit.text,".tres")
	current_song.note_list.sort_custom(func(a, b): return a.y < b.y)
	$save/FileDialog.visible = true
func _on_save_dialog_confirmed():
	ResourceSaver.save(current_song, $save/FileDialog.current_path)

func _on_upload_2_pressed():
	$upload2/FileDialog.visible = true

func _on_edit_dialog_confirmed():
	for n in $Panel.get_children():
		if n != $Panel/ColorRect: n.queue_free()
	current_song = ResourceLoader.load($upload2/FileDialog.current_path)
	if current_song.audio_track:
		$AudioStreamPlayer.stream = current_song.audio_track
		$HSlider.max_value = $AudioStreamPlayer.stream.get_length()
		$HSlider.value = 0.0
		$Label.text = str($HSlider.value, "s / ", $HSlider.max_value,"s")
		$HSlider.editable = true
	for n in current_song.note_list:
		place_note_vis(n.x, n.y)

func _on_test_pressed():
	if not current_song: return
	if not current_song.audio_track: return
	global.current_song = current_song
	get_tree().change_scene_to_file("res://test.tscn")
