extends Node

const CONFIG_FILEPATH = "user://config.json"
const CONFIG_VERSION_KEY = "config_version"
const LAST_FILE_KEY = "last_file"
const LAST_DIR_KEY = "last_dir"
const POSITION_KEY = "position_file"
const CURRENT_VERSION = 2

var config: Dictionary = {
	CONFIG_VERSION_KEY: 2,
	LAST_FILE_KEY: "",
	LAST_DIR_KEY: "",
	POSITION_KEY: {},
}

func _ready():
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

