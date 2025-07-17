extends RefCounted
class_name Project

const DEFAULT_ICON = preload("uid://b2qapuue4p2mj")

var _config_version: int = 0
var _name: String = ""
var _path: String = ""
var _icon_path: String = ""
var _modified_time: int = -1
var _tags: Array[String] = []
var _version: String = ""


func _init(config_file_path: String) -> void:
	setup_from_config_file(config_file_path)


func setup_from_config_file(config_file_path: String) -> void:
	var project_dir_path: String = config_file_path.replace("project.godot", "").replace("engine.cfg", "")
	var file: FileAccess = FileAccess.open(config_file_path, FileAccess.READ)
	var file_content: String = file.get_as_text()
	
	set_config_version(get_first_regex_find('%s(\\d+)' % ["config_version="], file_content).to_int())
	set_path(project_dir_path)
	
	set_name(_get_config_name(get_config_version(), file_content))
	set_icon_path(_get_config_icon(get_config_version(), file_content))
	
	set_modified_time(FileAccess.get_modified_time(config_file_path))
	
	set_tags(_get_config_tags(get_config_version(), file_content))
	set_version(_get_config_engine_version(get_config_version(), file_content))


static func _get_config_name(_unused, subject: String) -> String:
	var config_name: String = ""
	config_name = get_first_regex_find('%s"([^"]*)"' % ["config/name="], subject)
	if config_name == "":
		config_name = get_first_regex_find('%s"([^"]*)"' % ["name="], subject)
	return config_name

static func _get_config_icon(_unused, subject: String) -> String:
	var config_icon: String = ""
	config_icon = get_first_regex_find('%s"([^"]*)"' % ["config/icon="], subject)
	if config_icon == "":
		config_icon = get_first_regex_find('%s"([^"]*)"' % ["icon="], subject)
	return config_icon

static func _get_config_tags(_unused, subject: String) -> PackedStringArray:
	var config_tags: String = get_first_regex_find('%sPackedStringArray\\(([^)]+)\\)' % ["config/tags="], subject).replace("\"", "")
	if not config_tags.is_empty():
		return config_tags.split(", ")
	return []

static func _get_config_engine_version(_unused, subject: String) -> String:
	var config_features: String = get_first_regex_find('%sPackedStringArray\\(([^)]+)\\)' % ["config/features="], subject)
	if not config_features.is_empty():
		return config_features.get_slice(", ", 0).replace("\"", "")
	return "< 4.0"


func set_config_version(config_version: int) -> Project:
	_config_version = config_version
	return self

func set_name(name: String) -> Project:
	_name = name
	return self

func set_path(path: String) -> Project:
	_path = path.trim_suffix("/")
	return self

func set_modified_time(modified_time: int) -> Project:
	_modified_time = modified_time
	return self

func set_icon_path(icon_path: String) -> Project:
	if "res://" in icon_path:
		icon_path = icon_path.replace("res://", get_path()).replace("//", "/")
	_icon_path = icon_path
	return self

func set_tags(tags: Array[String]) -> Project:
	_tags = tags
	return self

func set_version(version: String) -> Project:
	_version = version
	return self


func get_config_version() -> int: return _config_version
func get_name() -> String: return _name
func get_path() -> String: return _path
func get_modified_time() -> int: return _modified_time
func get_icon() -> Texture2D:
	if not FileAccess.file_exists(ProjectSettings.globalize_path(_icon_path)):
		return DEFAULT_ICON
	var image = Image.load_from_file(ProjectSettings.globalize_path(_icon_path))
	if image == null:
		return DEFAULT_ICON
	return ImageTexture.create_from_image(image)
func get_tags() -> Array[String]: return _tags
func has_tags() -> bool: return not get_tags().is_empty()
func get_version() -> String: return _version

static func get_first_regex_find(pattern: String, subject: String) -> String:
	var regex: RegEx = RegEx.new()
	regex.compile(pattern)
	var result: RegExMatch = regex.search(subject)
	if not result:
		return ""
	return result.get_string(1)
