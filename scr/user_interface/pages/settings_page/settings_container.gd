extends VBoxContainer

const SETTING = preload("uid://cjqesasmg6gkc")

var _search_text: String = ""

@onready var smooth_scroll_container: SmoothScrollContainer = $".."


func set_search_text(text: String) -> void:
	_search_text = text


func update() -> void:
	clear()
	var settings: Array[Settings.SETTING]
	settings.assign(Settings.SETTING.values().duplicate())
	
	if not _search_text.is_empty():
		settings.assign(FuzzySearcher.mapped_search(_search_text, settings, func(setting: Settings.SETTING): return tr(SettingsManager.get_setting_data(setting).get_translation_key())))
	
	for setting: Settings.SETTING in settings:
		create_setting_ui(setting)
	smooth_scroll_container.set_deferred("scroll_vertical", 0)


func clear() -> void:
	for child in get_children():
		child.hide()
		child.queue_free()


func create_setting_ui(setting: Settings.SETTING) -> void:
	var setting_ui: SettingUI = SETTING.instantiate()
	add_child(setting_ui)
	setting_ui.setup.call_deferred(setting)
