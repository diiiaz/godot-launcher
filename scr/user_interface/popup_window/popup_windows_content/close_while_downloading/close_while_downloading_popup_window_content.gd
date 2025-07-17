extends PopupWindowContent
class_name CloseWhileDownlaodingPopupWindowContent

@onready var info_label: RichTextLabel = %InfoLabel


func setup(_extra_data: Variant) -> void:
	if not is_node_ready():
		await self.ready
		await get_tree().process_frame
	info_label.text = tr("CLOSE_APP_WHILE_DOWNLOADING_WARNING_LABEL").format({"color": ColorHelper.RED.to_html(false)})


func _on_close_app_button_pressed() -> void:
	user_input_result.emit(CloseWhileDownloadingResult.new(CloseWhileDownloadingResult.ACTION.CLOSE))

func _on_cancel_button_pressed() -> void:
	user_input_result.emit(CloseWhileDownloadingResult.new(CloseWhileDownloadingResult.ACTION.CANCEL))
	get_popup_window().close()


class CloseWhileDownloadingResult extends PopupWindowContent.Result:
	enum ACTION {
		CLOSE,
		CANCEL
	}
	var _action: ACTION
	
	func _init(action: ACTION) -> void:
		_action = action
	
	func get_action() -> ACTION: return _action
	func get_result_as_text() -> String: return "action: " + ACTION.keys()[get_action()].capitalize()
	func action_is_close() -> bool: return _action == ACTION.CLOSE
