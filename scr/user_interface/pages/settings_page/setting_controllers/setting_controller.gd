@abstract
extends Control
class_name SettingController

@abstract func set_value(value: Variant) -> void
@abstract func get_value_changed_signal() -> Signal

var _setting: Settings.SETTING


func _ready() -> void:
	get_value_changed_signal().connect(_on_value_changed)


func _on_value_changed(new_value: Variant) -> void:
	SettingsManager.set_setting(_setting, new_value)


func setup(_controller: SettingData.Controller) -> void:
	pass


func set_setting(setting: Settings.SETTING) -> void:
	_setting = setting
