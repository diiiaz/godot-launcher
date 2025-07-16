extends VBoxContainer
class_name ProjectsContainer

signal udpated

const PROJECT = preload("res://scr/user_interface/pages/projects_page/project.tscn")

var _sort_info: SortingMenuButton.SortInfo
var _filter_info: FilterMenuButton.FilterInfo
var _search_text: String = ""
var _page: int = 0


func _init() -> void:
	ProjectsManager.updated.connect(update)
	SettingsManager.updated.connect(
		func(setting: Settings.SETTING):
			if setting != Settings.SETTING.MAX_ITEMS_PER_PAGE:
				return
			update()
	)


func setup(sort_info: SortingMenuButton.SortInfo, filter_info: FilterMenuButton.FilterInfo) -> void:
	_sort_info = sort_info
	_filter_info = filter_info


func set_page(page: int) -> void:
	_page = wrapi(page, 0, ceil(ProjectsManager.get_projects_amount() / float(SettingsManager.get_setting(Settings.SETTING.MAX_ITEMS_PER_PAGE))))
	update()


func set_search_text(text: String) -> void:
	_search_text = text


func update() -> void:
	clear()
	for project in ProjectsManager.get_projects(
			_sort_info.get_selected_item().get_sort_method().bind(not _sort_info.is_inverted()),
			_filter_info.get_filter(),
			_search_text,
			_page * SettingsManager.get_setting(Settings.SETTING.MAX_ITEMS_PER_PAGE)
		):
		create_project_ui(project)
	udpated.emit()


func clear() -> void:
	for child in get_children():
		child.hide()
		child.queue_free()


func create_project_ui(project: Project) -> void:
	var project_ui: ProjectUI = PROJECT.instantiate()
	add_child(project_ui)
	project_ui.setup.call_deferred(project)
