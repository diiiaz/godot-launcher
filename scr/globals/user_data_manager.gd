@tool
extends Node
#class_name UserDataManager

signal updated(user_data: UserData.USER_DATA)

const USER_DATA_PATH = "user://user_data.tres"

var _user_data: UserData


func set_user_data(user_data: UserData.USER_DATA, value: Variant) -> void:
	_get_user_data().set_user_data(user_data, value)
	updated.emit(user_data)
	save_user_data()

func get_user_data(user_data: UserData.USER_DATA) -> Variant: return _get_user_data().get_user_data(user_data)
func get_user_data_fallback_value(user_data: UserData.USER_DATA) -> Variant: return _get_user_data().get_fallback_value(user_data)


func save_user_data() -> void:
	_remove_unused_projects_selected_version()
	ResourceSaver.save(_user_data, USER_DATA_PATH)


func _get_user_data() -> UserData:
	if _user_data == null:
		if not FileAccess.file_exists(USER_DATA_PATH):
			ResourceSaver.save(UserData.new(), USER_DATA_PATH)
		_user_data = ResourceLoader.load(USER_DATA_PATH)
	return _user_data


func _remove_unused_projects_selected_version() -> void:
	for project_path: String in get_user_data(UserData.USER_DATA.PROJECTS_SELECTED_BUILDS):
		if DirAccess.dir_exists_absolute(project_path):
			continue
		get_user_data(UserData.USER_DATA.PROJECTS_SELECTED_BUILDS).erase(project_path)


func get_godot_launcher_user_path() -> String:
	var user_path: String = OS.get_user_data_dir()
	user_path = user_path.replace(user_path.get_slice("/", user_path.get_slice_count("/") - 1), "")
	var launcher_user_path = user_path.path_join("Godot Launcher")
	return ProjectSettings.globalize_path(launcher_user_path)
