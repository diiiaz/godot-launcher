extends PopupWindowContent
class_name DeleteProjectPopupWindowContent

@onready var info_label: RichTextLabel = %InfoLabel
@onready var delete_project_button: Button = %DeleteProjectButton


func setup(extra_data: Variant) -> void:
	assert(extra_data is Project, "extra data for delete_project_popup_window_content.gd should be of type 'Project'.")
	var project: Project = extra_data
	if not is_node_ready():
		await self.ready
		await get_tree().process_frame
	info_label.text = tr("DELETE_PROJECT_WARNING_LABEL") % [ColorHelper.LIGHT_BLUE.to_html(false), project.get_name()]
	delete_project_button.text = tr("DELETE_PROJECT_CONFIRMATION") % [project.get_name()]


func _on_delete_project_button_pressed() -> void:
	get_popup_window().close()
	user_input_result.emit(DeleteProjectResult.new(DeleteProjectResult.ACTION.DELETE))


func _on_cancel_button_pressed() -> void:
	get_popup_window().close()
	user_input_result.emit(DeleteProjectResult.new(DeleteProjectResult.ACTION.CANCEL))


class DeleteProjectResult extends PopupWindowContent.Result:
	enum ACTION {
		DELETE,
		CANCEL
	}
	var _action: ACTION
	
	func _init(action: ACTION) -> void:
		_action = action
	
	func get_action() -> ACTION: return _action
	func get_result_as_text() -> String: return "action: " + ACTION.keys()[get_action()].capitalize()
	func action_is_delete() -> bool: return _action == ACTION.DELETE
