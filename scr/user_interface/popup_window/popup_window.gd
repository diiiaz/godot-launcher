extends Control
class_name PopupWindow

@onready var _title_label: Label = %TitleLabel
@onready var _window_panel: PanelContainer = %WindowPanel
@onready var _mouse_blocker: PanelContainer = %MouseBlocker
@onready var _content_container: Control = %ContentContainer


func _ready() -> void:
	_mouse_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_window_panel.modulate.a = 0.0
	_mouse_blocker.modulate.a = 0.0

func _on_close_button_pressed() -> void:
	close()


func open(title: String, content: PopupWindowContent) -> void:
	_mouse_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_title_label.text = title
	content.set_popup_window(self)
	_content_container.add_child(content)
	_window_panel.pivot_offset = _window_panel.size / 2.0
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).tween_property(_window_panel, "scale", Vector2.ONE, 0.2).from(Vector2.ONE * 0.8)
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).tween_property(_window_panel, "modulate:a", 1.0, 0.2).from(0.0)
	create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).tween_property(_mouse_blocker, "modulate:a", 1.0, 1.0).from(0.0)

func close() -> void:
	_mouse_blocker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).tween_property(_window_panel, "scale", Vector2.ONE * 0.8, 0.2).from(Vector2.ONE)
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).tween_property(_window_panel, "modulate:a", 0.0, 0.15).from(1.0)
	create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).tween_property(_mouse_blocker, "modulate:a", 0.0, 0.2).from(1.0)
	await get_tree().create_timer(0.2).timeout
	queue_free()
