extends VBoxContainer

var _viewer_packed: PackedScene = preload("res://scenes/comic_viewer.tscn")
@onready var _viewer_holder: Node = $ViewerHolder
@onready var _synchronize_setting: CheckBox = $MainControl/SynchronizeSetting
@onready var _add_reader_button: Button = $MainControl/AddReaderButton


@onready var _primary_viewer: ComicViewer = $ViewerHolder/ComicViewer
var _secondary_viewer: ComicViewer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_add_reader_button_pressed():
	_secondary_viewer = _viewer_packed.instantiate()
	_viewer_holder.add_child(_secondary_viewer)
	_secondary_viewer.connect("page_next", _on_comic_viewer_page_next.bind(false))
	_secondary_viewer.connect("page_prev", _on_comic_viewer_page_prev.bind(false))
	_add_reader_button.disabled = true

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
