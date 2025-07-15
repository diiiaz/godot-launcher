extends Resource
class_name UserData

# Dictionary[Project path, Godot build name]
@export var projects_selected_builds: Dictionary[String, String]

@export var check_new_version_timestamp: int = 0

@export var project_sort_option_index: int = 0
@export var project_sort_inverted: bool = false
