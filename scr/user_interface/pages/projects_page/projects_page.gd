extends Page

const CREATE_NEW_PROJECT_POPUP_WINDOW_CONTENT = preload("uid://dub2pm32m75ws")

@onready var sorting_menu_button: SortingMenuButton = %SortingMenuButton
@onready var tags_filter_menu_button: FilterMenuButton = %TagsFilterMenuButton
@onready var projects_container: ProjectsContainer = %ProjectsContainer
@onready var page_controller: PageController = %PageController

@onready var smooth_scroll_container: SmoothScrollContainer = %SmoothScrollContainer
@onready var bottom_panel_container: PanelContainer = %BottomPanelContainer
@onready var no_projects_found_label: RichTextLabel = %NoProjectsFoundLabel
@onready var no_projects_message_container: CenterContainer = %NoProjectsMessageContainer


func _ready() -> void:
	setup_sorting_menu_button()
	setup_tags_filter_menu_button()
	projects_container.setup(sorting_menu_button.get_sort_info(), tags_filter_menu_button.get_filter_info())
	page_controller.setup(func(): return ProjectsManager.get_projects_amount())
	ProjectsManager.updated.connect(page_controller.update)
	visibility_changed.connect(page_controller.update)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and no_projects_found_label != null:
		update_no_projects_found_label()

func get_icon() -> Texture2D:
	return preload("uid://dovk625lj7wf0")

func update_no_projects_found_label() -> void:
	no_projects_found_label.text = tr("NO_PROJECTS_FOUND_IN_DIR") % [ColorHelper.LIGHT_BLUE.to_html(false), SettingsManager.get_setting(Settings.SETTING.PROJECTS_PATH)]


# ---------------------------------- Projects Container

func _on_projects_container_udpated() -> void:
	smooth_scroll_container.visible = ProjectsManager.get_projects_amount() > 0
	bottom_panel_container.visible = ProjectsManager.get_projects_amount() > 0
	smooth_scroll_container.set_deferred("scroll_vertical", 0)
	no_projects_message_container.visible = not ProjectsManager.get_projects_amount() > 0
	update_no_projects_found_label()


# ---------------------------------- Change Projects Path Button

func _on_change_projects_path_button_pressed() -> void:
	var current_path: String = ProjectSettings.globalize_path(SettingsManager.get_setting(Settings.SETTING.PROJECTS_PATH))
	var file_dialog: FileDialog = DirectorySelector.create(_on_file_dialog_selected_directory)
	file_dialog.current_dir = ProjectSettings.globalize_path(current_path) if DirAccess.dir_exists_absolute(current_path) else SettingsManager.get_setting_fallback_value(Settings.SETTING.PROJECTS_PATH)
	get_viewport().add_child(file_dialog)

func _on_file_dialog_selected_directory(dir_path: String) -> void:
	SettingsManager.set_setting(Settings.SETTING.PROJECTS_PATH, dir_path)


# ---------------------------------- Search Bar

func _on_search_bar_text_changed(new_text: String) -> void:
	page_controller.travel_to_page(0)
	projects_container.set_search_text(new_text)
	projects_container.update()


# ---------------------------------- Sorting Menu Button

const SORT_BY_DATE_ICON_TEXTURE = preload("uid://cccs44sn3e3b6")
const SORT_BY_NAME_ICON_TEXTURE = preload("uid://c37ao0tstubqf")

func setup_sorting_menu_button() -> void:
	sorting_menu_button.setup([
		SortingMenuButton.SortItem.new("SORT_LAST_MODIFIED", SORT_BY_DATE_ICON_TEXTURE, _sort_by_date_function).add_inverted_options("SORT_NEWEST", "SORT_OLDEST"),
		SortingMenuButton.SortItem.new("SORT_NAME", SORT_BY_NAME_ICON_TEXTURE, _sort_by_name_function).add_inverted_options("SORT_DESCENDING", "SORT_ASCENDING"),
	],
	UserDataManager.get_user_data().project_sort_option_index,
	UserDataManager.get_user_data().project_sort_inverted)


func _sort_by_name_function(a: Project, b: Project, invert: bool = false) -> bool:
	return (a.get_name() > b.get_name()) if not invert else (a.get_name() < b.get_name())

func _sort_by_date_function(a: Project, b: Project, invert: bool = false) -> bool:
	return (a.get_modified_time() < b.get_modified_time()) if not invert else (a.get_modified_time() > b.get_modified_time())


func _on_sorting_menu_button_sorting_changed(sort_info: SortingMenuButton.SortInfo) -> void:
	UserDataManager.set_user_data("project_sort_option_index", sort_info.get_selected_index())
	UserDataManager.set_user_data("project_sort_inverted", sort_info.is_inverted())
	page_controller.travel_to_page(0)
	projects_container.update()


# ---------------------------------- Tags Filter Menu Button

func setup_tags_filter_menu_button() -> void:
	ProjectsManager.updated.connect(
		func():
			tags_filter_menu_button.clear_items()
			tags_filter_menu_button.disabled = TagsManager.get_tags_group(ProjectsManager.TAGS_GROUP_NAME).get_tags().is_empty()
			tags_filter_menu_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if tags_filter_menu_button.disabled else Control.CURSOR_POINTING_HAND
			for tag_name: String in TagsManager.get_tags_group(ProjectsManager.TAGS_GROUP_NAME).get_tags():
				tags_filter_menu_button.add_item(CustomMenuButton.Item.new().set_label(tag_name).set_checkable_type(CustomMenuButton.Item.CHECKABLE_TYPE.CHECKBOX))
	)

func _on_tags_filter_menu_button_filter_changed(_unused) -> void:
	page_controller.travel_to_page(0)
	projects_container.update()


# ---------------------------------- Page Controller

func _on_page_controller_changed_page(page_index: int) -> void:
	projects_container.set_page(page_index)


# ---------------------------------- Reload Button

func _on_reload_button_pressed() -> void:
	ProjectsManager.update_projects()


# ---------------------------------- Create New Project Button

func _on_create_new_project_button_pressed() -> void:
	var popup_content: CreateNewProjectPopupWindowContent = CREATE_NEW_PROJECT_POPUP_WINDOW_CONTENT.instantiate()
	popup_content.user_input_result.connect(_on_create_new_project_window_content_user_input_result)
	PopupWindowHelper.popup_window("CREATE_NEW_PROJECT", popup_content, get_viewport())

func _on_create_new_project_window_content_user_input_result(result: CreateNewProjectPopupWindowContent.CreateNewProjectResult) -> void:
	if result.has_canceled():
		return
	ProjectsManager.create_project(result.get_project_name(), result.get_project_path(), result.get_project_build())
	if result.is_editing_after():
		ProjectsManager.run_project(result.get_project_build(), result.get_project_path(), true)
