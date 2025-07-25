extends PanelContainer
class_name ProjectUI

signal tag_pressed(tag_name: String)
signal deleted

const TAG_UI = preload("uid://ekqlub7k865j")
const DELETE_PROJECT_POPUP_WINDOW_CONTENT = preload("uid://qwl6em84n25p")
const TAGS_MANAGER_POPUP_WINDOW_CONTENT = preload("uid://duskngwh068gh")

@onready var icon_texture_rect: TextureRect = %IconTextureRect
@onready var project_name_label: Label = %ProjectNameLabel
@onready var project_path_label: RichTextLabel = %ProjectPathLabel

@onready var last_edited_label: Label = %LastEditedLabel
@onready var version_label: Label = %VersionLabel

@onready var tags_container: HBoxContainer = %TagsContainer
@onready var tags_separator: VSeparator = %TagsSeparator

@onready var project_build_option_button: OptionButton = %ProjectBuildOptionButton

var _project: Project
var _build: EngineBuild


func setup(project: Project) -> void:
	_project = project
	
	if not _project.tags_changed.is_connected(update):
		_project.tags_changed.connect(update_tags)
	
	project_build_option_button.setup(_project)
	
	icon_texture_rect.texture = project.get_icon()
	icon_texture_rect.pivot_offset = icon_texture_rect.size / 2.0
	project_name_label.text = project.get_name()
	project_path_label.text = project.get_path()
	
	last_edited_label.text = TimeHelper.format_date_time_dict(TimeHelper.get_time_since_last_modified_date(project.get_modified_time()))
	version_label.text = project.get_version()
	
	update_tags()


func update() -> void:
	setup(_project)


func update_tags() -> void:
	tags_separator.visible = _project.has_tags()
	
	for child in tags_container.get_children():
		child.hide()
		child.queue_free()
	
	for tag: Tag in _project.get_tags():
		var tag_ui: TagUI = TAG_UI.instantiate()
		tags_container.add_child(tag_ui)
		tag_ui.setup(tag)
		tag_ui.pressed.connect(tag_pressed.emit)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _project != null:
		update()


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

func _on_manage_tags_button_pressed() -> void:
	var popup_content: PopupWindowContent = TAGS_MANAGER_POPUP_WINDOW_CONTENT.instantiate()
	popup_content.user_input_result.connect(_on_delete_project_popup_result)
	PopupWindowHelper.popup_window("POPUP_TITLE_MANAGE_TAGS", popup_content, get_viewport(), _project)


func _on_project_build_option_button_selected_build(build: EngineBuild) -> void:
	_build = build
	UserDataManager.get_user_data(UserData.USER_DATA.PROJECTS_SELECTED_BUILDS)[_project.get_path()] = _build.get_path().get_file()
	UserDataManager.save_user_data()

func _on_main_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == MOUSE_BUTTON_MASK_LEFT and event.double_click:
			ProjectsManager.run_project(_build, _project.get_path(), true)


func _on_project_path_button_pressed() -> void:
	OS.shell_open(_project.get_path())
