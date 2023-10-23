extends VBoxContainer
class_name ReaderPanel

@onready var _page_viewer: TextureRect = $PageViewer

var _zip_reader: ZIPReader
var _files: PackedStringArray
var _current_page_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_cbz_path(path: String)->void:
	_zip_reader = ZIPReader.new()
	var err := _zip_reader.open(path)
	if err != OK:
		push_error("Unable to read file", path, err)
		get_tree().quit()
	_files = _zip_reader.get_files()
	_files.sort()
	_current_page_index = 0
	if _files.size() > 0:
		_display_page()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _display_page()->void:
	var file_name: String = _files[_current_page_index]
	var res: PackedByteArray = _zip_reader.read_file(file_name)
	# write to file so we can load it
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
	var image_texture: ImageTexture = ImageTexture.create_from_image(Image.load_from_file(temp_file_name))
	var size:Vector2 = image_texture.get_size()
	_page_viewer.texture = image_texture
		
	
	
