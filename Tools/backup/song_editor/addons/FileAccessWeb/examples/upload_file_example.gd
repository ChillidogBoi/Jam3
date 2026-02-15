class_name UploadFileExample
extends Control

@export var file_extension: String

@onready var upload_button: Button = %"Upload Button" as Button
@onready var progress: ProgressBar = %"Progress Bar" as ProgressBar
@onready var success_label: Label = %"Success Label" as Label

var file_access_web: FileAccessWeb = FileAccessWeb.new()

func _ready() -> void:
	upload_button.pressed.connect(_on_upload_pressed)
	file_access_web.load_started.connect(_on_file_load_started)
	file_access_web.loaded.connect(_on_file_loaded)
	file_access_web.progress.connect(_on_progress)
	file_access_web.error.connect(_on_error)

func _on_file_load_started(file_name: String) -> void:
	progress.visible = true
	success_label.visible = false

func _on_upload_pressed() -> void:
	file_access_web.open()

func _on_progress(current_bytes: int, total_bytes: int) -> void:
	var percentage: float = float(current_bytes) / float(total_bytes) * 100
	progress.value = percentage

func _on_file_loaded(file_name: String, type: String, base64_data: String) -> void:
	progress.visible = false
	success_label.visible = true
	ResourceSaver.save(Marshalls.base64_to_variant(base64_data, true), str("upload.", file_extension))
	$"../FileDialog".current_path = str("/upload.", file_extension)
	$"../FileDialog".confirmed.emit()

func _on_error() -> void:
	push_error("Error!")
