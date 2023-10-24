extends VBoxContainer

var _reader_panel: PackedScene = preload("res://scenes/ReaderPanel.tscn")

@onready var _first_dialog: FileDialog = $FirstDialog
@onready var _dir_dialog: FileDialog = $DirDialog
@onready var _page_viewer: TextureRect = $PageViewer

var _zip_reader: ZIPReader
var _files: PackedStringArray
var _current_page_index: int = 0
var _dir_access: DirAccess

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_open_dialog_button_pressed():
	_first_dialog.visible = true
	
	
func _on_open_dir_button_pressed():
	_dir_dialog.visible = true


func _on_first_dialog_file_selected(path):
	_zip_reader = ZIPReader.new()
	_dir_access = null
	var err := _zip_reader.open(path)
	if err != OK:
		push_error("Unable to read file", path, err)
		get_tree().quit()
	_files = _zip_reader.get_files()
	_files.sort()
	_current_page_index = 0
	if _files.size() > 0:
		_display_page()

func _on_dir_dialog_dir_selected(dir):
	_dir_access = DirAccess.open(dir)
	if not _dir_access:
		push_error("Failed to open directory:", dir)
		get_tree().quit()
	_zip_reader = null
	_files = _build_files_from_directory(_dir_access)
	_current_page_index = 0
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
	var temp_file_name = ""
	if file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
		temp_file_name = "user://tmp_current_page.jpg"
	elif file_name.ends_with(".png"):
		temp_file_name = "user://tmp_current_page.png"
	else:
		push_error("Unsupported file:", file_name)
		get_tree().quit()
		
	var file = FileAccess.open(temp_file_name, FileAccess.WRITE)
	file.store_buffer(res)
	file.close()
	var image: Image = Image.load_from_file(temp_file_name)
#	var panel_size:Vector2 = _panel_container.size
	if image.get_height() > image.get_width():
		# height will be long edge
		pass
	else:
		# width will be long edge
		pass
	# scale with Image.resize()
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	var size:Vector2 = image_texture.get_size()
	_page_viewer.texture = image_texture
	
func _delete_children(node: Node)->void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()


func _on_prev_page_pressed():
	if _zip_reader == null and _dir_access == null:
		return
	if _current_page_index == 0:
		# can't go any further
		return
	_current_page_index -= 1
	_display_page()


func _on_next_page_pressed():
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
	


