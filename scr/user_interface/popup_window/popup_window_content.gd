@abstract
extends Control
class_name PopupWindowContent

@warning_ignore("unused_signal")
signal user_input_result(result: Result)


var _popup_window: PopupWindow


func setup(_extra_data: Variant) -> void:
	pass


func set_popup_window(popup_window: PopupWindow) -> void:
	_popup_window = popup_window


func get_popup_window() -> PopupWindow: return _popup_window
func get_window_size_ratio() -> Vector2: return Vector2(0.725, 0.725)


@abstract class Result extends RefCounted:
	@abstract func get_result_as_text() -> String
