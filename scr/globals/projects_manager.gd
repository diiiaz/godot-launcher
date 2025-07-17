extends Node


enum SORT_METHOD {
	NAME,
	DATE
}
const DEFAULT_ICON_PATH = "res://assets/textures/icons/default_icon.svg"
const PROJECT_ICON_NAME = "icon.svg"
const TAGS_GROUP_NAME = "projects"

signal updated
signal finished_initialization

static var _projects: Array[Project]


func initialize() -> void:
	SettingsManager.updated.connect(func(setting: Settings.SETTING): if setting == Settings.SETTING.PROJECTS_PATH: update_projects())
	SettingsManager.updated.connect(func(setting: Settings.SETTING): if setting == Settings.SETTING.BUILDS_PATH: update_projects())
	update_projects()
	finished_initialization.emit()


func get_projects_amount() -> int:
	return _projects.size()


func get_projects(sort_function: Callable = Callable(), tags_filter: PackedStringArray = [], string_filter: String = "", offset: int = 0) -> Array[Project]:
	var projects: Array[Project] = _projects.duplicate(true)
	
	if not tags_filter.is_empty():
		projects = projects.filter(func(project: Project): return project.get_tags().any(func(tag_name: String): return tag_name in tags_filter))
	
	if not string_filter.is_empty():
		projects.assign(FuzzySearcher.mapped_search(string_filter, projects, func(project: Project): return project.get_name()))
	
	if sort_function.is_valid():
		projects.sort_custom(sort_function)
	
	projects = projects.slice(offset, offset + SettingsManager.get_setting(Settings.SETTING.MAX_ITEMS_PER_PAGE))
	return projects


func delete_project(project: Project) -> Error:
	var error: Error = OS.move_to_trash(ProjectSettings.globalize_path(project.get_path()))
	if error != OK:
		ToastsManager.create_error_toast(tr("TOAST_DELETE_PROJECT_ERROR").format({"project_name": project.get_name(), "error": error_string(error)}))
		return error
	ToastsManager.create_info_toast(tr("TOAST_DELETED_PROJECT").format({"project_name": project.get_name()}))
	update_projects()
	if UserDataManager.get_user_data(UserData.USER_DATA.PROJECTS_SELECTED_BUILDS).has(project.get_path()):
		UserDataManager.get_user_data(UserData.USER_DATA.PROJECTS_SELECTED_BUILDS).erase(project.get_path())
		UserDataManager.save_user_data()
	return error


func is_dir_project_dir(dir_path: String) -> bool:
	var dir: DirAccess = DirAccess.open(dir_path)
	var files: PackedStringArray = dir.get_files()
	return "project.godot" in files or "engine.cfg" in files


func run_project(build: Build, project_path: String, in_editor: bool = false) -> void:
	if build == null:
		ToastsManager.create_warning_toast(tr("WARNING_PROJECT_RUN_WITHOUT_SELECTED_BUILD"))
		return
	OS.create_process(ProjectSettings.globalize_path(build.get_path()), ["--path", project_path, "--editor" if in_editor else ""])
	if SettingsManager.get_setting(Settings.SETTING.CLOSE_APP_ON_PROJECT_EDITING):
		get_tree().quit()


func get_project_config_file_name(dir_path: String) -> String:
	if not is_dir_project_dir(dir_path):
		return ""
	var dir: DirAccess = DirAccess.open(dir_path)
	var files: PackedStringArray = dir.get_files()
	if "project.godot" in files:
		return "project.godot"
	if "engine.cfg" in files:
		return "engine.cfg"
	return ""


func get_dir_contents(path) -> Array[String]:
	var directories: Array[String] = []
	var dir = DirAccess.open(path)
	var err: Error = DirAccess.get_open_error()
	if err != OK:
		ToastsManager.create_error_toast(tr("ERROR_DIR_ACCESS").format({"error": err}))
		return []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			directories.append(path.path_join(file_name))
		file_name = dir.get_next()
	return directories


func update_projects() -> void:
	_projects.clear()
	var path: String = SettingsManager.get_setting(Settings.SETTING.PROJECTS_PATH)
	
	if not DirAccess.dir_exists_absolute(path):
		ToastsManager.create_error_toast(tr("ERROR_NO_DIRECTORY_FOUND").format({"dir_path": path}))
		return
	
	TagsManager.get_tags_group(TAGS_GROUP_NAME).clear()
	for project_path: String in get_dir_contents(path):
		if not is_dir_project_dir(project_path):
			continue
		
		var project: Project = Project.new(project_path.path_join(get_project_config_file_name(project_path)))
		TagsManager.get_tags_group(TAGS_GROUP_NAME).add_tags(project.get_tags())
		_projects.append(project)
	updated.emit()


func create_project(project_name: String, project_path: String, build: Build) -> void:
	if not DirAccess.dir_exists_absolute(project_path):
		DirAccess.make_dir_recursive_absolute(project_path)
	ProjectConfigFile.create_project_config_file(project_name, project_path, build.get_version_name())
	DirAccess.copy_absolute(ProjectSettings.globalize_path(DEFAULT_ICON_PATH), project_path.path_join(PROJECT_ICON_NAME))
	UserDataManager.get_user_data(UserData.USER_DATA.PROJECTS_SELECTED_BUILDS)[project_path] = build.get_path().get_file()
	UserDataManager.save_user_data()
	await get_tree().process_frame
	ToastsManager.create_info_toast(tr("TOAST_CREATED_NEW_PROJECT").format({"project_name": project_name}))
	update_projects()
