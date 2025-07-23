extends Page

const TAGS_FILTER_ICON_TEXTURE = preload("uid://da4q4drae4qnk")

@onready var tags_filter_menu_button: FilterMenuButton = %TagsFilterMenuButton
@onready var releases_container: ReleasesContainer = %ReleasesContainer
@onready var page_controller: PageController = %PageController


func _ready() -> void:
	setup_tags_filter_menu_button()
	releases_container.setup(tags_filter_menu_button.get_filter_info())
	page_controller.setup(func(): return await EngineBuildsManager.get_releases_amount())
	EngineBuildsManager.updated.connect(page_controller.update)
	visibility_changed.connect(page_controller.update)

func get_icon() -> Texture2D:
	return preload("uid://dsrtamnxenut4")


func _on_releases_container_tag_pressed(tag: Tag) -> void:
	for index: int in range(tags_filter_menu_button.get_popup().item_count):
		if tags_filter_menu_button.get_popup().get_item_text(index) == tag.get_name():
			tags_filter_menu_button.set_filter(index, true)
			return


# ---------------------------------- Tags Filter Menu Button

func setup_tags_filter_menu_button() -> void:
	EngineBuildsManager.updated.connect(
		func():
			tags_filter_menu_button.clear_items()
			tags_filter_menu_button.disabled = TagsManager.get_or_create_tag_group(Release.TAG_GROUP).get_tags().is_empty()
			tags_filter_menu_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if tags_filter_menu_button.disabled else Control.CURSOR_POINTING_HAND
			for tag: Tag in TagsManager.get_or_create_tag_group(Release.TAG_GROUP).get_tags():
				tags_filter_menu_button.add_item(
					CustomMenuButton.Item.new()
						.set_label(tag.get_name())
						.set_checkable_type(CustomMenuButton.Item.CHECKABLE_TYPE.CHECKBOX)
						.set_color(Color.from_ok_hsl(tag.get_hue(), 0.8, 0.8))
						.set_icon(TAGS_FILTER_ICON_TEXTURE)
				)
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
	EngineBuildsManager.check_for_new_releases()
