extends Node

const CONFIG_FILEPATH = "user://config.json"
const CONFIG_VERSION_KEY = "config_version"
const LAST_FILE_KEY = "last_file"
const LAST_DIR_KEY = "last_dir"
const POSITION_KEY = "position_file"
const RESUME_KEY = "resume_on_open"
const CURRENT_VERSION = 4

var config_default: Dictionary = {
	CONFIG_VERSION_KEY: 4,
	LAST_FILE_KEY: "",
	LAST_DIR_KEY: "",
	POSITION_KEY: {},
	RESUME_KEY: false,
	"reader_state": {
		"left": {
			"is_file": false,
			"path": "",
		},
		"right": {
			"visible": false,
			"is_file": false,
			"path": "",
		}
	}
}

var config: Dictionary = {}

func _ready():
	config = config_default
	_initialize()

func _initialize()->void:
	if FileAccess.file_exists(CONFIG_FILEPATH):
		var contents: String = FileAccess.get_file_as_string(CONFIG_FILEPATH)
		if contents != "":
			var json := JSON.new()
			var error = json.parse(contents)
			if typeof(json.data) == TYPE_DICTIONARY:
				config = json.data
				_migrate()

func _migrate()->void:
	if config[CONFIG_VERSION_KEY] < CURRENT_VERSION:
		while config[CONFIG_VERSION_KEY] < CURRENT_VERSION:
			if config[CONFIG_VERSION_KEY] == 1:
				config[POSITION_KEY] = {}
			elif config[CONFIG_VERSION_KEY] == 2:
				config[RESUME_KEY] = false
			elif config[CONFIG_VERSION_KEY] == 3:
				config["reader_state"] = config_default["reader_state"]
			else:
				# this is an unhandled config upgrade which is a bad thing
				# let's fail gracefully for now.
				push_error("Unhandled configuration upgrade")
				config = config_default
			config[CONFIG_VERSION_KEY] += 1
		_save()

func _save()->void:
	var file: = FileAccess.open(CONFIG_FILEPATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(config))
	file.close()
	
func set_last_file_open_path(path: String)->void:
	config[LAST_FILE_KEY] = path
	_save()
	
func get_folder_of_last_file_open()->String:
	if config[LAST_FILE_KEY] == "":
		return ""
	var regex = RegEx.new()
	regex.compile("/[^/]*$")
	var re_result := regex.search(config[LAST_FILE_KEY])
	var path = (config[LAST_FILE_KEY] as String).substr(0, re_result.get_start())
	if not DirAccess.dir_exists_absolute(path):
		return ""
	return path

func set_last_dir_open_path(path: String)->void:
	config[LAST_DIR_KEY] = path
	_save()
	
func get_last_dir_open_path()->String:
	if config[LAST_DIR_KEY] == "":
		return ""
	if not DirAccess.dir_exists_absolute(config[LAST_DIR_KEY]):
		return ""
	return config[LAST_DIR_KEY]
	
func set_read_position(path: String, position: int)->void:
	if path != "":
		config[POSITION_KEY][path] = position
		_save()
		
func get_read_position(path)->int:
	if not (config[POSITION_KEY] as Dictionary).has(path):
		return 0
	return int(config[POSITION_KEY][path])
	
func set_resume(enabled: bool)->void:
	config[RESUME_KEY] = enabled
	_save()

func get_resume()->bool:
	return config[RESUME_KEY] as bool
	
func get_reader_state()->Dictionary:
	return config["reader_state"]
	
func set_reader_state(is_left: bool, is_file: bool, path: String)->void:
	if is_left:
		config["reader_state"]["left"] = {
			"is_file": is_file,
			"path": path,
		}
	else:
		config["reader_state"]["right"] = {
			"visible": true,
			"is_file": is_file,
			"path": path,
		}
	_save()
	
func is_right_visible()->bool:
	return config["reader_state"]["right"]["visible"] as bool
	
func set_right_visible(visible: bool)->void:
	config["reader_state"]["right"]["visible"] = visible
	_save()
