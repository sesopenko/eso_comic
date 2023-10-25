extends VBoxContainer
class_name ComicViewer

@onready var _first_dialog: FileDialog = $FileDialog
@onready var _dir_dialog: FileDialog = $DirDialog
@onready var _page_viewer: TextureRect = $PageViewer

signal page_next()
signal page_prev()

var _zip_reader: ZIPReader
var _files: PackedStringArray
var _current_page_index: int = 0
var _dir_access: DirAccess
var _file_path: String = ""

var _mouse_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _mouse_active:
		if Input.is_action_just_released("page_next"):
			change_next()
			emit_signal("page_next")
		if Input.is_action_just_released("page_prev"):
			change_prev()
			emit_signal("page_prev")


func _on_open_dialog_button_pressed():
	var path: String = get_node("/root/Config").call("get_folder_of_last_file_open")
	if path != "":
		_first_dialog.current_dir = path
	_first_dialog.visible = true
	
	
func _on_open_dir_button_pressed():
	var path: String = get_node("/root/Config").call("get_last_dir_open_path")
	if path != "":
		_dir_dialog.current_dir = path
	_dir_dialog.visible = true


func _on_first_dialog_file_selected(path):
	_file_path = path
	get_node("/root/Config").call("set_last_file_open_path", path)
	_zip_reader = ZIPReader.new()
	_dir_access = null
	var err := _zip_reader.open(path)
	if err != OK:
		push_error("Unable to read file", path, err)
		get_tree().quit()
	_files = _zip_reader.get_files()
	_files.sort()
	_current_page_index = get_node("/root/Config").get_read_position(_file_path)
	if _files.size() > 0:
		_display_page()

func _on_dir_dialog_dir_selected(dir):
	_file_path = dir
	get_node("/root/Config").call("set_last_dir_open_path", dir)
	_dir_access = DirAccess.open(dir)
	if not _dir_access:
		push_error("Failed to open directory:", dir)
		get_tree().quit()
	_zip_reader = null
	_files = _build_files_from_directory(_dir_access)
	_current_page_index = get_node("/root/Config").get_read_position(_file_path)
	if _files.size() > 0:
		_display_page()

func _build_files_from_directory(dir_access: DirAccess)->PackedStringArray:
	var files: PackedStringArray = PackedStringArray()
	dir_access.list_dir_begin()
	var file_name: String = dir_access.get_next()
	while file_name != "":
		if not dir_access.current_is_dir():
			if file_name.ends_with(".jpg") or file_name.ends_with(".png") or file_name.ends_with(".jpeg"):
				files.append(file_name)
		file_name = dir_access.get_next()
	files.sort()
	return files
	
func _display_page()->void:
	var file_name: String = _files[_current_page_index]
	var res: PackedByteArray
	if _zip_reader != null:
		# we're reading a zip file
		res = _zip_reader.read_file(file_name)
	elif _dir_access != null:
		# we're reading a raw file
		var path: String = str(_dir_access.get_current_dir(), "/", file_name)
		res = FileAccess.get_file_as_bytes(path)
	# write to file so we can load it
	# this step may be unecessary but haven't tried refactoring into loading
	# image directly from bytes.
	var image: Image = Image.new()
	if file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
		image.load_jpg_from_buffer(res)
	elif file_name.ends_with(".png"):
		image.load_png_from_buffer(res)
	else:
		push_error("Unsupported file extension:", file_name)
		get_tree().quit()
		
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	var size:Vector2 = image_texture.get_size()
	_page_viewer.texture = image_texture
	get_node("/root/Config").set_read_position(_file_path, _current_page_index)
	
func _delete_children(node: Node)->void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func change_next()->void:
	if _zip_reader == null and _dir_access == null:
		return
	if _files.size() == 0:
		# can't go anywhere
		return
	if _current_page_index >= _files.size() - 1:
		# can't go any further
		return
	_current_page_index += 1
	_display_page()

func change_prev()->void:
	if _zip_reader == null and _dir_access == null:
		return
	if _current_page_index == 0:
		# can't go any further
		return
	_current_page_index -= 1
	_display_page()

func _on_prev_page_pressed():
	change_prev()
	emit_signal("page_prev")


func _on_next_page_pressed():
	change_next()
	emit_signal("page_next")
	


func _on_mouse_entered():
	_mouse_active = true


func _on_mouse_exited():
	_mouse_active = false
