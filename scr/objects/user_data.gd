extends Resource
class_name UserData

# Dictionary[Project path, Godot build name]
@warning_ignore("unused_private_class_variable")
@export var _projects_selected_builds: Dictionary[String, String]

@warning_ignore("unused_private_class_variable")
@export var _check_new_version_timestamp: int = 0

@warning_ignore("unused_private_class_variable")
@export var _project_sort_option_index: int = 0

@warning_ignore("unused_private_class_variable")
@export var _project_sort_inverted: bool = false


enum USER_DATA {
	PROJECTS_SELECTED_BUILDS,
	CHECK_NEW_VERSION_TIMESTAMP,
	PROJECT_SORT_OPTION_INDEX,
	PROJECT_SORT_INVERTED,
}

static var _user_data_variable_map: Dictionary[USER_DATA, String] = {
	USER_DATA.PROJECTS_SELECTED_BUILDS: "_projects_selected_builds",
	USER_DATA.CHECK_NEW_VERSION_TIMESTAMP: "_check_new_version_timestamp",
	USER_DATA.PROJECT_SORT_OPTION_INDEX: "_project_sort_option_index",
	USER_DATA.PROJECT_SORT_INVERTED: "_project_sort_inverted",
}

static var _user_data_fallback_value_map: Dictionary[USER_DATA, Variant] = {
	USER_DATA.PROJECTS_SELECTED_BUILDS: {},
	USER_DATA.CHECK_NEW_VERSION_TIMESTAMP: 0,
	USER_DATA.PROJECT_SORT_OPTION_INDEX: 0,
	USER_DATA.PROJECT_SORT_INVERTED: false,
}


func get_user_data(user_data: USER_DATA) -> Variant:
	return get(_user_data_variable_map.get(user_data))

func set_user_data(user_data: USER_DATA, value: Variant) -> void:
	return set(_user_data_variable_map.get(user_data), value)

func get_fallback_value(user_data: USER_DATA) -> Variant:
	return _user_data_fallback_value_map.get(user_data)
