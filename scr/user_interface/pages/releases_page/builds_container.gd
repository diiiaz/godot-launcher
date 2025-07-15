extends Control
class_name BuildsContainer

const BUILD = preload("uid://6vmkyybil4d3")

@onready var smooth_scroll_container: SmoothScrollContainer = %BuilldsSmoothScrollContainer
@onready var no_releases_selected_container: CenterContainer = %NoReleasesSelectedContainer

var _release: Release
var _search_text: String


func load_builds(release: Release) -> void:
	_release = release
	clear()
	smooth_scroll_container.visible = true
	no_releases_selected_container.visible = false
	smooth_scroll_container.scroll_vertical = 0
	var builds: Array[Build] = release.get_builds().duplicate(true)
	
	if not _search_text.is_empty():
		builds.assign(FuzzySearcher.mapped_search(_search_text, builds, func(build: Build): return build.get_name()))
	
	builds.sort_custom(func(build_a: Build, build_b: Build): return build_a.get_name() < build_b.get_name())
	
	for build: Build in builds:
		var build_ui: BuildUI = BUILD.instantiate()
		add_child(build_ui)
		build_ui.setup(build)


func update_builds() -> void:
	if _release != null:
		load_builds(_release)


func _on_search_bar_text_changed(new_text: String) -> void:
	_search_text = new_text
	update_builds()


func clear() -> void:
	for child in get_children():
		child.hide()
		child.queue_free()


func _on_releases_container_release_pressed(_release_ui: ReleaseUI, release: Release) -> void:
	load_builds(release)
