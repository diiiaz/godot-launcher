extends PanelContainer
class_name TagUIEditor

signal pressed

@onready var tag_name_line_edit: LineEdit = %TagNameLineEdit
@onready var hash_background_panel_container: PanelContainer = %HashBackgroundPanelContainer

var _tag_group: TagGroup
var _tag: Tag


func setup(tag: Tag) -> void:
	_tag_group = TagsManager.get_or_create_tag_group(Project.TAG_GROUP)
	_tag = tag
	_tag_group.renamed_tag.connect(
		func(renamed_tag: Tag, _unused):
			if renamed_tag != _tag:
				return
			update()
	)
	update()

func update() -> void:
	tag_name_line_edit.text = _tag.get_name()
	hash_background_panel_container.self_modulate = Color.from_ok_hsl(_tag.get_hue(), 0.8, 0.8)


func _on_tag_name_line_edit_text_submitted(new_text: String) -> void:
	_tag_group.rename_tag(_tag, new_text)

func _on_edit_button_pressed() -> void:
	tag_name_line_edit.grab_focus()
	tag_name_line_edit.caret_column = tag_name_line_edit.text.length()

func _on_delete_button_pressed() -> void:
	_tag_group.delete_tag(_tag)

func _on_main_button_pressed() -> void:
	pressed.emit()
