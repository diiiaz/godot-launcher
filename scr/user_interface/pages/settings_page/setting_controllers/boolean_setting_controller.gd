extends SettingController

@export var checkbox: CheckBox


func set_value(value: Variant) -> void:
	checkbox.button_pressed = value


func get_value_changed_signal() -> Signal:
	return checkbox.toggled
