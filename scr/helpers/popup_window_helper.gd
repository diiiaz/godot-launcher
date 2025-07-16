extends RefCounted
class_name PopupWindowHelper

const POPUP_WINDOW = preload("uid://ctlltenahpe6b")


static func popup_window(title: String, content: PopupWindowContent, parent: Node, extra_data: Variant = null) -> PopupWindow:
	var _popup_window: PopupWindow = POPUP_WINDOW.instantiate()
	parent.add_child(_popup_window)
	content.setup(extra_data)
	_popup_window.open(title, content)
	return _popup_window
