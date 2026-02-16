extends Control

const NOTE = preload("uid://duopt6ew2xshj")

var dragging = false
var current_song: song
var start_audio_back = false
var sel_note
var sel_time: float
var file_access_web: FileAccessWeb
signal test

func _ready():
	if global.current_song:
		current_song = global.current_song
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
	if OS.get_name() == "Web":
		file_access_web = FileAccessWeb.new()

func _on_button_pressed():
	if file_access_web:
		file_access_web = FileAccessWeb.new()
		file_access_web.open(".ogg, .mp3, .wav")
		file_access_web.loaded.connect(_on_audio_web_loaded)
	else: $upload/FileDialog.visible = true

func _on_audio_web_loaded(file_name, file_type, base64_data):
	print(base64_data)
	$AudioStreamPlayer.stream = Marshalls.base64_to_variant(base64_data, true)
	
	$HSlider.max_value = $AudioStreamPlayer.stream.get_length()
	$HSlider.value = 0.0
	$Label.text = str($HSlider.value, "s / ", $HSlider.max_value,"s")
	$HSlider.editable = true
	if current_song: current_song.audio_track = $AudioStreamPlayer.stream

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
	c.texture_normal = c.texture_normal.duplicate()
	c.texture_pressed = c.texture_pressed.duplicate()
	c.texture_hover = c.texture_hover.duplicate()
	c.texture_normal.region.position.x = 32.0 * type
	c.texture_pressed.region.position.x = 32.0 * type
	c.texture_hover.region.position.x = 32.0 * type
	c.position.y = 40
	c.position.x = ((time/$HSlider.max_value) * $Panel.size.x) - 5
	c.pressed.connect(erase_note.bind(c, time))

func erase_note(note: TextureButton, time: float):
	sel_note = note
	sel_time = time

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
	if file_access_web:
		var tmp = Marshalls.variant_to_base64(current_song, true)
		tmp = tmp.to_utf8_buffer()
		JavaScriptBridge.download_buffer(tmp, str($LineEdit.text,".tres"))
	else: $save/FileDialog.visible = true
func _on_save_dialog_confirmed():
	ResourceSaver.save(current_song, $save/FileDialog.current_path)

func _on_upload_2_pressed():
	if file_access_web:
		file_access_web = FileAccessWeb.new()
		file_access_web.open(".tres")
		file_access_web.loaded.connect(_on_tres_web_loaded)
	else: $upload2/FileDialog.visible = true

func _on_tres_web_loaded(file_name, file_type, base64_data):
	for n in $Panel.get_children():
		if n != $Panel/ColorRect: n.queue_free()
	current_song = Marshalls.base64_to_variant(base64_data, true)
	if current_song.audio_track:
		$AudioStreamPlayer.stream = current_song.audio_track
		$HSlider.max_value = snapped($AudioStreamPlayer.stream.get_length(), 0.001)
		$HSlider.value = 0.0
		$Label.text = str($HSlider.value, "s / ", $HSlider.max_value,"s")
		$HSlider.editable = true
	for n in current_song.note_list:
		place_note_vis(n.x, n.y)

func _on_edit_dialog_confirmed():
	for n in $Panel.get_children():
		if n != $Panel/ColorRect: n.queue_free()
	current_song = ResourceLoader.load($upload2/FileDialog.current_path)
	if current_song.audio_track:
		$AudioStreamPlayer.stream = current_song.audio_track
		$HSlider.max_value = snapped($AudioStreamPlayer.stream.get_length(), 0.001)
		$HSlider.value = 0.0
		$Label.text = str($HSlider.value, "s / ", $HSlider.max_value,"s")
		$HSlider.editable = true
	$LineEdit.text = current_song.song_name
	$LineEdit.editable = true
	for n in current_song.note_list:
		place_note_vis(n.x, n.y)

func _on_test_pressed():
	if not current_song: return
	if not current_song.audio_track: return
	global.current_song = current_song
	get_tree().change_scene_to_file("res://test.tscn")

func _on_panel_gui_input(event):
	if not current_song: return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and sel_note:
		sel_note.position.x = event.position.x
		for n in current_song.note_list:
			if n.y == sel_time: n.y = snapped(event.position.x / $Panel.size.x * $HSlider.max_value, 0.001)
	if event is InputEventMouseMotion: return
	if not event.is_pressed(): return
	if event.button_index == 4:
		if $Panel.size.x > 10000: return
		$Panel.size.x += 300
		$Panel.position.x -= 150
		$HScrollBar.max_value = $Panel.size.x - 1142
		$HScrollBar.value = -$Panel.position.x
		for n in $Panel.get_children():
			if n != $Panel/ColorRect: n.queue_free()
		for n in current_song.note_list:
			place_note_vis(n.x, n.y)
	elif event.button_index == 5:
		if $Panel.size.x < 1200: return
		$Panel.size.x -= 300
		$Panel.position.x += 150
		$HScrollBar.max_value = $Panel.size.x - 1142
		$HScrollBar.value = -$Panel.position.x
		for n in $Panel.get_children():
			if n != $Panel/ColorRect: n.queue_free()
		for n in current_song.note_list:
			place_note_vis(n.x, n.y)

func _on_delete_pressed():
	if not sel_note: return
	sel_note.queue_free()
	for n in current_song.note_list:
		if n.y == sel_time: current_song.note_list.erase(n)


func _on_h_scroll_bar_value_changed(value):
	$Panel.position.x = -value


func _on_change_note_pressed():
	if not sel_note: return
	for n in current_song.note_list:
		if n.y == sel_time: n.x = $add_note/Button.selected
	sel_note.texture_normal = sel_note.texture_normal.duplicate()
	sel_note.texture_pressed = sel_note.texture_pressed.duplicate()
	sel_note.texture_hover = sel_note.texture_hover.duplicate()
	sel_note.texture_normal.region.position.x = 32.0 * $add_note/Button.selected
	sel_note.texture_pressed.region.position.x = 32.0 * $add_note/Button.selected
	sel_note.texture_hover.region.position.x = 32.0 * $add_note/Button.selected


func _on_spin_box_1_value_changed(value):
	detection_change(1, value)
func _on_spin_box_2_value_changed(value):
	detection_change(2, value)
func _on_spin_box_3_value_changed(value):
	detection_change(3, value)

func detection_change(variant:int, value:float):
	if not current_song: return
	match variant:
		1: current_song.detection.x = value
		2: current_song.detection.y = value
		3: current_song.detection.z = value
