extends RefCounted
class_name ProjectConfigFile

const CONFIG_FILE_TEMPLATE: String = "; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

{config_version}

[application]

{config_key}name=\"{project_name}\"
{config_key}icon=\"res://icon.svg\"

[editor_plugins]

enabled=PackedStringArray({plugins})
"

## Generates a project.godot (or engine.cfg if version is old) file at the specified path.
static func create_project_config_file(
	project_name: String,
	project_path: String,
	godot_version: String,
	add_addon: bool = false
		) -> void:
	
	var file: FileAccess = FileAccess.open(project_path.path_join(get_config_file_name(godot_version)), FileAccess.WRITE)
	
	if file:
		#var content: String = CONFIG_FILE_COMMENT_HEADER + "\n" + get_config_version(godot_version) + "\n" + get_config_parameters(godot_version)
		var content: String = CONFIG_FILE_TEMPLATE.format({
			"config_version": get_config_version(godot_version),
			"config_key": get_config_key(godot_version),
			"project_name": project_name,
			"plugins": "\"res://addons/godot-launcher-quit-to-launcher/plugin.cfg\"" if add_addon else "" 
		})
		file.store_string(content)
		file.close()
	else:
		ToastsManager.create_error_toast(error_string(FileAccess.get_open_error()))


static func get_config_version(godot_version: String) -> String:
	var string: String = "config_version=%s"
	var splitted_version: PackedStringArray = godot_version.split(".")
	var first_number: int = splitted_version[0].to_int()
	var second_number: int = splitted_version[1].to_int()
	# if we are in 4.0+ config version is 5
	if first_number >= 4: return string % 5
	# if we are between 3.1 and 4.0 config version is 4
	elif first_number >= 3 and second_number > 0: return string % 4
	# if we are between 3.0 and 3.0.6 config version is 3
	elif first_number >= 3 and second_number == 0: return string % 3
	# if we are below 3.0 there is no config_version in the config file
	else: return ""


static func get_config_key(godot_version: String) -> String:
	var splitted_version: PackedStringArray = godot_version.split(".")
	var first_number: int = splitted_version[0].to_int()
	# if we are in versions from 1.0 - 2.1.4 we do nothing, else, we add a "config/" to the param name
	var config_key: String = "config/" if first_number >= 3 else ""
	return config_key


static func get_config_file_name(godot_version: String) -> String:
	var splitted_version: PackedStringArray = godot_version.split(".")
	var first_number: int = splitted_version[0].to_int()
	if first_number < 3:
		# config file name for godot 1.0 - 2.1.4
		return "engine.cfg"
	# config file name for godot 3.0+
	return "project.godot"
