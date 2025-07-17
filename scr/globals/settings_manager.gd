extends Node
#class_name SettingsManager

signal updated(setting: Settings.SETTING)

const SETTINGS_PATH = "user://settings.tres"

var _settings: Settings


func set_setting(setting: Settings.SETTING, value: Variant) -> void:
	_get_settings().set_setting(setting, value)
	updated.emit(setting)
	save_settings()

func get_setting(setting: Settings.SETTING) -> Variant: return _get_settings().get_setting(setting)
func get_setting_data(setting: Settings.SETTING) -> SettingData: return _get_settings().get_setting_data(setting)
func get_setting_fallback_value(setting: Settings.SETTING) -> Variant: return _get_settings().get_fallback_value(setting)

func save_settings() -> void:
	ResourceSaver.save(_settings, SETTINGS_PATH)


func _get_settings() -> Settings:
	if _settings == null:
		if not FileAccess.file_exists(SETTINGS_PATH):
			ResourceSaver.save(Settings.new(), SETTINGS_PATH)
		_settings = ResourceLoader.load(SETTINGS_PATH)
	return _settings
