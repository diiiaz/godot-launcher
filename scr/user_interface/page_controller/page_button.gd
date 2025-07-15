extends Control
class_name PageButton

const ELLIPSIS_STRING = "..."

signal pressed

@onready var label: Label = %Label
@onready var button: Button = %Button

var _old_page_number: int = -1
var _page_number: int = -1
var _old_text: String = ""
var _wanted_text: String = ""
var _label_pos: Vector2


func _ready() -> void:
	_label_pos = label.position


func set_page_number(number: int) -> void:
	_old_page_number = _page_number
	_page_number = number
	_old_text = _wanted_text
	_wanted_text = str(str(_page_number) if _page_number >= 0 else ELLIPSIS_STRING)
	button.disabled = not _wanted_text.is_valid_int()
	button.mouse_default_cursor_shape = Control.CURSOR_ARROW if not _wanted_text.is_valid_int() else Control.CURSOR_POINTING_HAND


func animate_text() -> void:
	if _wanted_text == label.text:
		return
	
	var direction: int = 0 if not _wanted_text.is_valid_int() or not _old_text.is_valid_int() or (_old_page_number - _page_number) == 0 else 1 if _old_page_number > _page_number else -1
	var animation_direction: Vector2 = Vector2(direction, 0)
	
	var _text_tweener: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_parallel()
	_text_tweener.tween_property(label, "modulate:a", 0.0, 0.1).from(1.0).set_ease(Tween.EASE_IN)
	_text_tweener.tween_property(label, "position", _label_pos + animation_direction * 10, 0.1).from(_label_pos).set_ease(Tween.EASE_IN)
	_text_tweener.chain().tween_property(label, "text", _wanted_text, 0.0)
	_text_tweener.chain().tween_property(label, "position", _label_pos, 0.1).from(-animation_direction * 10).set_ease(Tween.EASE_OUT)
	_text_tweener.tween_property(label, "modulate:a", 1.0, 0.1).from(0.0).set_ease(Tween.EASE_OUT)


func get_page_number() -> int:
	return _page_number

func _on_button_pressed() -> void:
	pressed.emit()
