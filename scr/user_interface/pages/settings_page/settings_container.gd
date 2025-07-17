extends VBoxContainer

const SETTING_CATEGORY_HEADER = preload("uid://c8x7e5whnksyn")

var _search_text: String = ""

@onready var smooth_scroll_container: SmoothScrollContainer = $".."


func set_search_text(text: String) -> void:
	_search_text = text


func update() -> void:
	clear()
	var categories: Array[Settings.SettingCategory]
	categories.assign(Settings.get_categories().duplicate())
	
	if not _search_text.is_empty():
		categories.assign(
			FuzzySearcher.mapped_search(_search_text, categories,
				func(category: Settings.SettingCategory):
					var string: String = ""
					for setting: Settings.SETTING in category.get_settings():
						string += tr(SettingsManager.get_setting_data(setting).get_translation_key()) + ","
					return string.left(-1)
					)
				)
	
	for category: Settings.SettingCategory in categories:
		create_setting_category(category)
	
	smooth_scroll_container.set_deferred("scroll_vertical", 0)


func clear() -> void:
	for child in get_children():
		child.hide()
		child.queue_free()

func create_setting_category(category: Settings.SettingCategory) -> void:
	var category_ui: Control = SETTING_CATEGORY_HEADER.instantiate()
	add_child(category_ui)
	category_ui.setup.call_deferred(category, _search_text)
