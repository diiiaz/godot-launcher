extends Page

@onready var tags_filter_menu_button: FilterMenuButton = %TagsFilterMenuButton
@onready var releases_container: ReleasesContainer = %ReleasesContainer
@onready var page_controller: PageController = %PageController


func _ready() -> void:
	setup_tags_filter_menu_button()
	releases_container.setup(tags_filter_menu_button.get_filter_info())
	page_controller.setup(func(): return await BuildsManager.get_releases_amount())
	BuildsManager.updated.connect(page_controller.update)
	visibility_changed.connect(page_controller.update)

func get_icon() -> Texture2D:
	return preload("uid://dsrtamnxenut4")


# ---------------------------------- Tags Filter Menu Button

func setup_tags_filter_menu_button() -> void:
	BuildsManager.updated.connect(
		func():
			tags_filter_menu_button.clear_items()
			tags_filter_menu_button.disabled = TagsManager.get_tags_group(BuildsManager.TAGS_GROUP_NAME).get_tags().is_empty()
			tags_filter_menu_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if tags_filter_menu_button.disabled else Control.CURSOR_POINTING_HAND
			for tag_name: String in TagsManager.get_tags_group(BuildsManager.TAGS_GROUP_NAME).get_tags():
				tags_filter_menu_button.add_item(CustomMenuButton.Item.new().set_label(tag_name).set_checkable_type(CustomMenuButton.Item.CHECKABLE_TYPE.CHECKBOX))
	)

func _on_tags_filter_menu_button_filter_changed(_unused) -> void:
	page_controller.travel_to_page(0)
	releases_container.update()


# ---------------------------------- Search bar

func _on_search_bar_text_changed(new_text: String) -> void:
	page_controller.travel_to_page(0)
	releases_container.set_search_text(new_text)
	releases_container.update()


# ---------------------------------- Page Controller

func _on_page_controller_changed_page(page_index: int) -> void:
	releases_container.set_page(page_index)


# ---------------------------------- Reload Button

func _on_reload_button_pressed() -> void:
	page_controller.travel_to_page(0)
	releases_container.update()
	BuildsManager.check_for_new_releases()
