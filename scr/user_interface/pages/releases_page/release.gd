extends PanelContainer
class_name ReleaseUI

const TAG_UI = preload("uid://ekqlub7k865j")

signal pressed

@onready var release_name_label: Label = %ReleaseNameLabel
@onready var tags_separator: VSeparator = %TagsSeparator
@onready var tags_container: HBoxContainer = %TagsContainer

@onready var builds_downloaded_container: HBoxContainer = %BuildsDownloadedContainer
@onready var builds_downloaded_label: Label = %BuildsDownloadedLabel
@onready var release_time_label: Label = %ReleaseTimeLabel

@onready var download_recommended_build_button: Button = %DownloadRecommendedBuildButton
@onready var delete_recommended_build_button: Button = %DeleteRecommendedBuildButton

var _release: Release


func setup(release: Release) -> void:
	_release = release
	if not _release.build_downloaded.is_connected(_on_release_build_downloaded):
		_release.build_downloaded.connect(_on_release_build_downloaded)
	if not _release.build_uninstalled.is_connected(_on_release_build_uninstalled):
		_release.build_uninstalled.connect(_on_release_build_uninstalled)
	#builds_container_controller.setup(release)
	release_name_label.text = "Godot " + release.get_name()
	
	download_recommended_build_button.visible = not release.get_recommended_build().is_downloaded()
	delete_recommended_build_button.visible = release.get_recommended_build().is_downloaded()
	
	download_recommended_build_button.tooltip_text = "%s (%s)" % [tr("TOOLTIP_DOWNLOAD_RECOMMENDED_BUILD"), _release.get_recommended_build().get_name()]
	delete_recommended_build_button.tooltip_text = "%s (%s)" % [tr("TOOLTIP_DELETE_RECOMMENDED_BUILD"), _release.get_recommended_build().get_name()]
	
	builds_downloaded_container.modulate.a = 1.0 if not release.get_downloaded_builds().is_empty() else 0.3
	builds_downloaded_label.text = tr("DOWNLOADED_BUILDS_AMOUNT") % release.get_downloaded_builds().size()
	release_time_label.text = TimeHelper.format_date_time_dict(TimeHelper.get_time_since_last_modified_date(release.get_published_time()))
	
	tags_separator.visible = release.has_tags()
	
	for child in tags_container.get_children():
		child.hide()
		child.queue_free()
	
	for tag_name: String in release.get_tags():
		var tag_ui = TAG_UI.instantiate()
		tags_container.add_child(tag_ui)
		tag_ui.setup(tag_name)


func update() -> void:
	if _release != null:
		setup(_release)
		#update_builds()

func update_builds() -> void:
	pressed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _release != null:
		update()


func _on_download_recommended_build_button_pressed() -> void:
	BuildDownloader.download(_release.get_recommended_build())

func _on_open_source_button_pressed() -> void:
	OS.shell_open(_release.get_html_url())

func _on_open_changelog_button_pressed() -> void:
	OS.shell_open(_release.get_interactive_changelog_url())

func _on_main_button_pressed() -> void:
	update_builds()

func _on_delete_recommended_build_button_pressed() -> void:
	BuildsManager.uninstall_build(_release.get_recommended_build())

func _on_view_all_builds_button_pressed() -> void:
	update_builds()


func _on_release_build_downloaded() -> void:
	update()

func _on_release_build_uninstalled() -> void:
	update()
	update_builds()

#func _on_uninstall_asset_button_pressed() -> void:
	#if _asset.is_downloaded():
		#var err: Error = DirAccess.remove_absolute(_asset.get_path())
		#if err != OK:
			#ToastsManager.create_error_toast(error_string(err))
		#else:
			#ToastsManager.create_info_toast(tr("SUCCESS_UNINSTALLED_ASSET") % [_asset.get_name()])
		#await get_tree().process_frame
		#if not _asset.is_downloaded():
			#_asset.uninstalled.emit()
			#update()
