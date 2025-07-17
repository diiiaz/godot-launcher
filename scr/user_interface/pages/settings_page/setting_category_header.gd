extends PanelContainer

const SETTING = preload("uid://cjqesasmg6gkc")

@onready var category_name_label: Label = %CategoryNameLabel
@onready var category_icon_texture_rect: TextureRect = %CategoryIconTextureRect
@onready var settings_container: VBoxContainer = %SettingsContainer


func setup(category: Settings.SettingCategory, search_text: String = "") -> void:
	category_name_label.text = category.get_name()
	category_icon_texture_rect.texture = category.get_icon()
	
	var settings: Array[Settings.SETTING]
	settings.assign(category.get_settings().duplicate())
	
	if not search_text.is_empty():
		settings.assign(FuzzySearcher.mapped_search(search_text, settings, func(setting: Settings.SETTING): return tr(SettingsManager.get_setting_data(setting).get_translation_key())))
	
	for setting: Settings.SETTING in settings:
		create_setting_ui(setting)
	

func create_setting_ui(setting: Settings.SETTING) -> void:
	var setting_ui: SettingUI = SETTING.instantiate()
	settings_container.add_child(setting_ui)
	setting_ui.setup.call_deferred(setting)
