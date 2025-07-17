extends Resource
class_name Settings

enum SETTING {
	LANGUAGE,
	BUILDS_PATH,
	PROJECTS_PATH,
	MAX_ITEMS_PER_PAGE,
	USE_MONO_BUILDS,
	CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP,
	CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP,
	CLOSE_APP_ON_PROJECT_EDITING,
}

static var _setting_variable_map: Dictionary[SETTING, String] = {
	SETTING.LANGUAGE: "_language",
	SETTING.BUILDS_PATH: "_builds_path",
	SETTING.PROJECTS_PATH: "_projects_path",
	SETTING.MAX_ITEMS_PER_PAGE: "_max_items_per_page",
	SETTING.USE_MONO_BUILDS: "_use_mono_version",
	SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP: "_check_for_new_engine_releases_on_startup",
	SETTING.CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP: "_check_for_new_engine_releases_on_startup",
	SETTING.CLOSE_APP_ON_PROJECT_EDITING: "_close_app_on_project_editing",
}

static var _setting_fallback_value_map: Dictionary[SETTING, Variant] = {
	SETTING.LANGUAGE: 0,
	SETTING.BUILDS_PATH: ProjectSettings.globalize_path("user://builds/"),
	SETTING.PROJECTS_PATH: ProjectSettings.globalize_path("user://projects/"),
	SETTING.MAX_ITEMS_PER_PAGE: 20,
	SETTING.USE_MONO_BUILDS: false,
	SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP: true,
	SETTING.CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP: true,
	SETTING.CLOSE_APP_ON_PROJECT_EDITING: true,
}

static var _setting_data_map: Dictionary[SETTING, SettingData] = {
	SETTING.LANGUAGE: SettingData.new(
		"SETTING_LANGUAGE", "SETTING_TOOLTIP_LANGUAGE",
		SettingData.ControllerOption.new().add_options(_get_translation_local_names())),
	
	SETTING.BUILDS_PATH: SettingData.new(
		"SETTING_BUILDS_PATH", "SETTING_TOOLTIP_BUILDS_PATH",
		SettingData.ControllerPath.new()),
	
	SETTING.PROJECTS_PATH: SettingData.new(
		"SETTING_PROJECTS_PATH", "SETTING_TOOLTIP_PROJECTS_PATH",
		SettingData.ControllerPath.new()),
	
	SETTING.MAX_ITEMS_PER_PAGE: SettingData.new(
		"SETTING_MAX_ITEMS_PER_PAGE", "SETTING_TOOLTIP_MAX_ITEMS_PER_PAGE",
		SettingData.ControllerNumber.new().set_range(5, 30, 1)),
	
	SETTING.USE_MONO_BUILDS: SettingData.new(
		"SETTING_USE_MONO_BUILDS", "SETTING_TOOLTIP_USE_MONO_BUILDS",
		SettingData.ControllerBoolean.new()),
	
	SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP: SettingData.new(
		"SETTING_CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP", "SETTING_TOOLTIP_CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP",
		SettingData.ControllerBoolean.new()),
	
	SETTING.CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP: SettingData.new(
		"SETTING_CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP", "SETTING_TOOLTIP_CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP",
		SettingData.ControllerBoolean.new()),
	
	SETTING.CLOSE_APP_ON_PROJECT_EDITING: SettingData.new(
		"SETTING_CLOSE_APP_ON_PROJECT_EDITING", "SETTING_TOOLTIP_CLOSE_APP_ON_PROJECT_EDITING",
		SettingData.ControllerBoolean.new()),
	
}

static var _categories: Array[SettingCategory] = [
	SettingCategory.new("SETTING_LANGUAGE", preload("uid://dyo407o1h2ov3"))
		.add_setting(SETTING.LANGUAGE),
	SettingCategory.new("SETTING_CATEGORY_PATHS", preload("uid://dvxij2arp75im"))
		.add_setting(SETTING.BUILDS_PATH)
		.add_setting(SETTING.PROJECTS_PATH),
	SettingCategory.new("SETTING_CATEGORY_CHECK_FOR_NEW_RELEASES_ON_STARTUP", preload("uid://6hb8qsb6ss1u"))
		.add_setting(SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP)
		.add_setting(SETTING.CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP),
	SettingCategory.new("SETTING_CATEGORY_OTHER", preload("uid://cdtu1dxs2afjl"))
		.add_setting(SETTING.MAX_ITEMS_PER_PAGE)
		.add_setting(SETTING.USE_MONO_BUILDS)
		.add_setting(SETTING.CLOSE_APP_ON_PROJECT_EDITING),
]


@warning_ignore("unused_private_class_variable")
@export_storage var _language: int = 0

@warning_ignore("unused_private_class_variable")
@export_storage var _builds_path: String = ProjectSettings.globalize_path("user://builds/")

@warning_ignore("unused_private_class_variable")
@export_storage var _projects_path: String = ProjectSettings.globalize_path("user://projects/")

@warning_ignore("unused_private_class_variable")
@export_storage var _max_items_per_page: int = 20

@warning_ignore("unused_private_class_variable")
@export_storage var _use_mono_version: bool = false

@warning_ignore("unused_private_class_variable")
@export_storage var _check_for_new_engine_releases_on_startup: bool = true

@warning_ignore("unused_private_class_variable")
@export_storage var _check_for_new_launcher_releases_on_startup: bool = true

@warning_ignore("unused_private_class_variable")
@export_storage var _close_app_on_project_editing: bool = true


func get_setting(setting: SETTING) -> Variant:
	return get(_setting_variable_map.get(setting))

func set_setting(setting: SETTING, value: Variant) -> void:
	return set(_setting_variable_map.get(setting), value)

func get_setting_data(setting: SETTING) -> SettingData:
	return _setting_data_map.get(setting)

func get_fallback_value(setting: SETTING) -> Variant:
	return _setting_fallback_value_map.get(setting)

static func get_categories() -> Array[SettingCategory]:
	return _categories


static func _get_translation_local_names() -> PackedStringArray:
	var arr: Array[String]
	for local_name: String in TranslationServer.get_loaded_locales():
		arr.append(TranslationServer.get_translation_object(local_name).get_message("LOCAL_NAME"))
	return arr


class SettingCategory extends RefCounted:
	var _name: String = ""
	var _icon: Texture2D = null
	var _settings: Array[SETTING]
	
	func _init(name: String, icon: Texture2D) -> void:
		_name = name
		_icon = icon
	
	func add_setting(setting: SETTING) -> SettingCategory:
		_settings.append(setting)
		return self
	
	func get_name() -> String: return _name
	func get_icon() -> Texture2D: return _icon
	func get_settings() -> Array[SETTING]: return _settings
