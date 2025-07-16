extends VBoxContainer
class_name ReleasesContainer

const RELEASE = preload("uid://cba7grhb7105l")

signal release_pressed(release_ui: ReleaseUI, release: Release)

var _filter_info: FilterMenuButton.FilterInfo
var _search_text: String = ""
var _page: int = 0

@onready var smooth_scroll_container: SmoothScrollContainer = %ReleasesSmoothScrollContainer

func _init() -> void:
	BuildsManager.updated.connect(update)
	SettingsManager.updated.connect(
		func(setting: Settings.SETTING):
			if setting != Settings.SETTING.MAX_ITEMS_PER_PAGE:
				return
			update()
	)


func setup(filter_info: FilterMenuButton.FilterInfo) -> void:
	_filter_info = filter_info


func set_page(page: int) -> void:
	_page = wrapi(page, 0, ceil(await BuildsManager.get_releases_amount() / float(SettingsManager.get_setting(Settings.SETTING.MAX_ITEMS_PER_PAGE))))
	update()


func set_search_text(text: String) -> void:
	_search_text = text


func update() -> void:
	clear()
	for release: Release in await BuildsManager.get_releases(
			_filter_info.get_filter(),
			_search_text,
			_page * SettingsManager.get_setting(Settings.SETTING.MAX_ITEMS_PER_PAGE)
		):
			create_release_ui(release)
	smooth_scroll_container.set_deferred("scroll_vertical", 0)


func clear() -> void:
	for child in get_children():
		child.hide()
		child.queue_free()


func create_release_ui(release: Release) -> void:
	var release_ui: ReleaseUI = RELEASE.instantiate()
	add_child(release_ui)
	release_ui.setup.call_deferred(release)
	release_ui.pressed.connect(func(): release_pressed.emit(release_ui, release))
