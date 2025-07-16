extends PanelContainer
class_name ProjectUI

signal deleted

const TAG_UI = preload("uid://ekqlub7k865j")
const DELETE_PROJECT_POPUP_WINDOW_CONTENT = preload("uid://qwl6em84n25p")

@onready var icon_texture_rect: TextureRect = %IconTextureRect
@onready var project_name_label: Label = %ProjectNameLabel
@onready var project_path_label: Label = %ProjectPathLabel

@onready var last_edited_label: Label = %LastEditedLabel
@onready var version_label: Label = %VersionLabel

@onready var tags_container: HBoxContainer = %TagsContainer
@onready var tags_separator: VSeparator = %TagsSeparator

@onready var project_build_option_button: OptionButton = %ProjectBuildOptionButton

var _project: Project
var _build: Build


func setup(project: Project) -> void:
	_project = project
	
	project_build_option_button.setup(_project)
	
	icon_texture_rect.texture = project.get_icon()
	icon_texture_rect.pivot_offset = icon_texture_rect.size / 2.0
	project_name_label.text = project.get_name()
	project_path_label.text = project.get_path()
	
	last_edited_label.text = TimeHelper.format_date_time_dict(TimeHelper.get_time_since_last_modified_date(project.get_modified_time()))
	version_label.text = project.get_version()
	
	tags_separator.visible = project.has_tags()
	
	for child in tags_container.get_children():
		child.hide()
		child.queue_free()
	
	for tag_name: String in project.get_tags():
		var tag_ui = TAG_UI.instantiate()
		tags_container.add_child(tag_ui)
		tag_ui.setup(tag_name)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _project != null:
		setup(_project)


func _on_play_button_pressed() -> void: ProjectsManager.run_project(_build, _project.get_path(), false)
func _on_edit_button_pressed() -> void: ProjectsManager.run_project(_build, _project.get_path(), true)

func _on_delete_button_pressed() -> void:
	var popup_content: PopupWindowContent = DELETE_PROJECT_POPUP_WINDOW_CONTENT.instantiate()
	popup_content.user_input_result.connect(_on_delete_project_popup_result)
	PopupWindowHelper.popup_window("POPUP_TITLE_DELETE_PROJECT", popup_content, get_viewport(), _project)

func _on_delete_project_popup_result(result: PopupWindowContent.Result) -> void:
	if result.action_is_delete():
		ProjectsManager.delete_project(_project)
		deleted.emit()


func _on_project_build_option_button_selected_build(build: Build) -> void:
	_build = build
	UserDataManager.get_user_data().projects_selected_builds[_project.get_path()] = _build.get_path().get_file()
	UserDataManager.save_user_data()

func _on_main_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.double_click:
			ProjectsManager.run_project(_build, _project.get_path(), true)
