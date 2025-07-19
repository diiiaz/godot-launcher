extends PopupWindowContent
class_name CreateNewProjectPopupWindowContent

const STATUS_ERROR_ICON_TEXTURE = preload("uid://bw8oxtvrnpwq3")
const STATUS_SUCCESS_ICON_TEXTURE = preload("uid://dl5251qp6cx1y")

@onready var project_name_line_edit: LineEdit = %ProjectNameLineEdit
@onready var project_path_label: Label = %ProjectPathLabel

@onready var project_path_status_label: Label = %ProjectPathStatusLabel
@onready var project_path_status_texture_rect: TextureRect = %ProjectPathStatusTextureRect

@onready var build_status_label: Label = %BuildStatusLabel
@onready var build_status_texture_rect: TextureRect = %BuildStatusTextureRect

@onready var create_edit_button: Button = %CreateEditButton
@onready var create_button: Button = %CreateButton

var _current_project_name: String = ""
var _current_project_path: String = ""
var _selected_build: EngineBuild


func _ready() -> void:
	SettingsManager.updated.connect(_on_settings_manager_updated)
	project_name_line_edit.text = tr("DEFAULT_NEW_GAME_PROJECT_NAME")
	_current_project_name = project_name_line_edit.text
	update()


func _on_settings_manager_updated(setting: Settings.SETTING) -> void:
	if setting == Settings.SETTING.PROJECTS_PATH:
		update()

func _on_project_name_line_edit_text_changed(new_text: String) -> void:
	_current_project_name = new_text if new_text != "" else tr("UNTITLED_PROJECT_NAME")
	update()


func update() -> void:
	_current_project_path = SettingsManager.get_setting(Settings.SETTING.PROJECTS_PATH).path_join(_validate_project_name_for_path(_current_project_name))
	project_path_label.text = _current_project_path
	project_path_label.tooltip_text = _current_project_path
	
	var path_is_valid: bool = _is_path_valid()
	project_path_status_label.text = "INFO_PROJECT_DIR_CREATE_AUTO" if path_is_valid else "ERROR_DIRECTORY_NOT_EMPTY"
	project_path_status_label.modulate = ColorHelper.LIGHT_GREEN if path_is_valid else ColorHelper.LIGHT_RED
	project_path_status_texture_rect.texture = STATUS_SUCCESS_ICON_TEXTURE if path_is_valid else STATUS_ERROR_ICON_TEXTURE
	project_path_status_texture_rect.self_modulate = ColorHelper.LIGHT_GREEN if path_is_valid else ColorHelper.LIGHT_RED
	
	var build_is_valid: bool = _selected_build != null
	build_status_label.text = "INFO_BUILD_VALID" if build_is_valid else "INFO_BUILD_NULL"
	build_status_label.modulate = ColorHelper.LIGHT_GREEN if build_is_valid else ColorHelper.LIGHT_RED
	build_status_texture_rect.texture = STATUS_SUCCESS_ICON_TEXTURE if build_is_valid else STATUS_ERROR_ICON_TEXTURE
	build_status_texture_rect.self_modulate = ColorHelper.LIGHT_GREEN if build_is_valid else ColorHelper.LIGHT_RED
	
	create_edit_button.disabled = not (path_is_valid and build_is_valid)
	create_button.disabled = not (path_is_valid and build_is_valid)


func _validate_project_name_for_path(project_name: String) -> String:
	const INVALID_CHARS = ' .:?*"<>|\\/'
	var valid_path = ""
	#project_name = project_name if project_name != "" else tr("UNTITLED_PROJECT_NAME")
	project_name = project_name.to_kebab_case()
	
	for i in range(project_name.length()):
		var _char: String = project_name[i]
		var char_code = _char.unicode_at(0)
		
		if INVALID_CHARS.find(_char) != -1 or char_code < 32:
			valid_path += "-"
		else:
			valid_path += _char
	
	valid_path = valid_path.strip_edges(true, true)
	return valid_path


func _is_path_valid() -> bool:
	if DirAccess.dir_exists_absolute(_current_project_path):
		if DirAccess.get_files_at(_current_project_path).is_empty() and DirAccess.get_directories_at(_current_project_path).is_empty():
			return true
		return false
	return true


func _on_change_projects_path_button_pressed() -> void:
	var current_path: String = ProjectSettings.globalize_path(SettingsManager.get_setting(Settings.SETTING.PROJECTS_PATH))
	var file_dialog: FileDialog = DirectorySelector.create(_on_file_dialog_selected_directory)
	file_dialog.current_dir = ProjectSettings.globalize_path(current_path) if DirAccess.dir_exists_absolute(current_path) else SettingsManager.get_setting_fallback_value(Settings.SETTING.PROJECTS_PATH)
	get_viewport().add_child(file_dialog)

func _on_file_dialog_selected_directory(dir_path: String) -> void:
	SettingsManager.set_setting(Settings.SETTING.PROJECTS_PATH, dir_path)

func _on_open_directory_button_pressed() -> void:
	OS.shell_open(SettingsManager.get_setting(Settings.SETTING.PROJECTS_PATH))



func _on_create_button_pressed() -> void:
	user_input_result.emit(CreateNewProjectResult.new(CreateNewProjectResult.ACTION.CREATE).setup_new_project(_current_project_name, _current_project_path, _selected_build))
	get_popup_window().close()

func _on_create_edit_button_pressed() -> void:
	user_input_result.emit(CreateNewProjectResult.new(CreateNewProjectResult.ACTION.CREATE_EDIT).setup_new_project(_current_project_name, _current_project_path, _selected_build))
	get_popup_window().close()

func _on_cancel_button_pressed() -> void:
	user_input_result.emit(CreateNewProjectResult.new(CreateNewProjectResult.ACTION.CANCEL))
	get_popup_window().close()


func _on_build_option_button_selected_build(build: EngineBuild) -> void:
	_selected_build = build
	update()


class CreateNewProjectResult extends PopupWindowContent.Result:
	enum ACTION {
		CREATE_EDIT,
		CREATE,
		CANCEL
	}
	var _action: ACTION
	var _project_name: String
	var _project_path: String
	var _project_build: EngineBuild
	
	func _init(action: ACTION) -> void:
		_action = action
	
	func setup_new_project(name: String = "", path: String = "", build: EngineBuild = null) -> CreateNewProjectResult:
		_project_name = name
		_project_path = path
		_project_build = build
		return self
	
	func get_action() -> ACTION: return _action
	func get_project_name() -> String: return _project_name
	func get_project_path() -> String: return _project_path
	func get_project_build() -> EngineBuild: return _project_build
	func get_result_as_text() -> String: return "action: " + ACTION.keys()[get_action()] + ", project_name: " + _project_name + ", project_path: " + _project_path + ", project_build: " + _project_build.get_name() if _project_build != null else "none"
	func has_canceled() -> bool: return _action == ACTION.CANCEL
	func is_editing_after() -> bool: return _action == ACTION.CREATE_EDIT
