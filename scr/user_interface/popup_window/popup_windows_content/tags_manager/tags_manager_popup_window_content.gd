extends PopupWindowContent
class_name TagsManagerPopupWindowContent

const TAG_UI_EDITOR = preload("uid://b4ymg7l804jgx")

@onready var project_tags_container: HFlowContainer = %ProjectTagsHFlowContainer
@onready var all_tags_container: HFlowContainer = %AllTagsHFlowContainer
@onready var project_tag_label: Label = %ProjectTagLabel


var _project: Project

func get_window_size_ratio() -> Vector2: return Vector2.ONE * 0.8


func setup(extra_data: Variant) -> void:
	assert(extra_data is Project, "extra data for delete_project_popup_window_content.gd should be of type 'Project'.")
	if not is_node_ready():
		await self.ready
		await get_tree().process_frame
	_project = extra_data
	project_tag_label.text = tr("PROJECT_TAGS") % [_project.get_name()]
	TagsManager.tag_group_changed.connect(_on_tag_group_changed)
	_update()


func _on_tag_group_changed(tag_group: TagGroup) -> void:
	if tag_group.get_group_name() != Project.TAG_GROUP:
		return
	_update()


func _update() -> void:
	for child in project_tags_container.get_children() + all_tags_container.get_children():
		child.hide()
		child.queue_free()
	
	for tag: Tag in TagsManager.get_or_create_tag_group(Project.TAG_GROUP).get_tags():
		var project_has_tag: bool = _project.has_tag(tag)
		var container: Control = project_tags_container if project_has_tag else all_tags_container
		var tag_ui_editor: TagUIEditor = _create_tag_ui_editor(tag, container)
		var function_to_call: Callable = (_project.remove_tag if project_has_tag else _project.add_tag).bind(tag)
		tag_ui_editor.pressed.connect(
			func():
				function_to_call.call()
				_update()
		)
	
	all_tags_container.add_child(_create_add_new_tag_button())


func _create_add_new_tag_button() -> Button:
	var create_tag_button: Button = Button.new()
	create_tag_button.theme_type_variation = "ButtonSimple"
	create_tag_button.tooltip_text = "TOOLTIP_CREATE_TAG"
	create_tag_button.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	create_tag_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	create_tag_button.custom_minimum_size = Vector2.ONE * 16
	create_tag_button.icon = preload("uid://wwa67pf51v78")
	create_tag_button.pressed.connect(_on_create_new_tag_button_pressed)
	return create_tag_button


func _on_create_new_tag_button_pressed() -> void:
	TagsManager.get_or_create_tag_group(Project.TAG_GROUP).create_tag(tr("NEW_TAG_NAME"))


func _create_tag_ui_editor(tag: Tag, container: Control) -> TagUIEditor:
	var tag_ui_editor: TagUIEditor = TAG_UI_EDITOR.instantiate()
	container.add_child(tag_ui_editor)
	tag_ui_editor.setup(tag)
	return tag_ui_editor
