extends RefCounted
class_name UserDataManager

const USER_DATA_PATH = "user://user_data.tres"

static var _user_data: UserData


static func get_user_data() -> UserData:
	if _user_data == null:
		if not FileAccess.file_exists(USER_DATA_PATH):
			ResourceSaver.save(UserData.new(), USER_DATA_PATH)
		_user_data = ResourceLoader.load(USER_DATA_PATH)
	return _user_data


static func set_user_data(user_data_name: String, value: Variant) -> void:
	if _user_data == null:
		if not FileAccess.file_exists(USER_DATA_PATH):
			ResourceSaver.save(UserData.new(), USER_DATA_PATH)
		_user_data = ResourceLoader.load(USER_DATA_PATH)
	_user_data.set(user_data_name, value)
	save_user_data()


static func save_user_data() -> void:
	_remove_unused_projects_selected_version()
	ResourceSaver.save(_user_data, USER_DATA_PATH)


static func _remove_unused_projects_selected_version() -> void:
	for project_path: String in _user_data.projects_selected_builds:
		if DirAccess.dir_exists_absolute(project_path):
			continue
		_user_data.projects_selected_builds.erase(project_path)
