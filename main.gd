extends VBoxContainer

var _viewer_packed: PackedScene = preload("res://scenes/comic_viewer.tscn")
@onready var _viewer_holder: Node = $ViewerHolder
@onready var _synchronize_setting: CheckBox = $MainControl/SynchronizeSetting
@onready var _add_reader_button: Button = $MainControl/AddReaderButton
@onready var _resume_checkbox: CheckBox = $MainControl/ResumeCheckbox
@onready var _primary_viewer: ComicViewer = $ViewerHolder/ComicViewer

var _secondary_viewer: ComicViewer

# Called when the node enters the scene tree for the first time.
func _ready():
	_resume_checkbox.button_pressed = get_node("/root/Config").get_resume()
	if _resume_checkbox.button_pressed:
		_perform_resume()
	_add_reader_button.button_pressed = get_node("/root/Config").is_right_visible()

func _perform_resume()->void:
	var reader_state: Dictionary = get_node("/root/Config").get_reader_state()
	if reader_state["left"]["path"] != "":
		var left_path: String =  reader_state["left"]["path"] as String
		if reader_state["left"]["is_file"]:
			_primary_viewer.open_zip_file_path(left_path)
		else:
			_primary_viewer.open_dir_path(left_path)

func _add_reader():
	_secondary_viewer = _viewer_packed.instantiate()
	_viewer_holder.add_child(_secondary_viewer)
	_secondary_viewer.connect("page_next", _on_comic_viewer_page_next.bind(false))
	_secondary_viewer.connect("page_prev", _on_comic_viewer_page_prev.bind(false))
	_secondary_viewer.connect("opened", _on_secondary_opened_file)
	var reader_state: Dictionary = get_node("/root/Config").get_reader_state()
	var right_path: String = reader_state["right"]["path"] as String
	if right_path != "":
		if reader_state["right"]["is_file"]:
			_secondary_viewer.open_zip_file_path(right_path)
		else:
			_secondary_viewer.open_dir_path(right_path)
		
func _on_secondary_opened_file(is_file: bool, path: String):
	get_node("/root/Config").set_reader_state(false, is_file, path)

func _on_comic_viewer_page_next(is_primary: bool):
	if _synchronize_setting.button_pressed:
		if not is_primary:
			_primary_viewer.change_next()
		else:
			if _secondary_viewer:
				_secondary_viewer.change_next()

func _on_comic_viewer_page_prev(is_primary: bool):
	if _synchronize_setting.button_pressed:
		if not is_primary:
			_primary_viewer.change_prev()
		else:
			if _secondary_viewer:
				_secondary_viewer.change_prev()

func _on_resume_checkbox_toggled(button_pressed: bool):
	get_node("/root/Config").set_resume(button_pressed)

func _on_comic_viewer_opened(is_file, path, is_left):
	if is_left:
		get_node("/root/Config").set_reader_state(is_left, is_file, path)

func _on_add_reader_button_toggled(button_pressed):
	if not button_pressed:
		if _secondary_viewer:
			_secondary_viewer.queue_free()
			_secondary_viewer = null
	else:
		_add_reader()
	get_node("/root/Config").set_right_visible(button_pressed)
