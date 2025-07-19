extends PanelContainer
class_name BuildUI

const TAG_UI = preload("uid://ekqlub7k865j")

@onready var build_name_label: Label = %BuildNameLabel
#@onready var tags_container: HBoxContainer = %TagsContainer
@onready var size_label: Label = %SizeLabel
@onready var download_button: Button = %DownloadButton
@onready var delete_button: Button = %DeleteButton

var _build: EngineBuild


func setup(build: EngineBuild) -> void:
	_build = build
	if not build.downloaded.is_connected(_on_build_downloaded):
		build.downloaded.connect(_on_build_downloaded)
	build_name_label.text = build.get_name()
	size_label.text = MemorySizeHelper.format_file_size(build.get_size())
	
	download_button.visible = not build.is_downloaded()
	delete_button.visible = build.is_downloaded()


func update() -> void:
	if _build != null:
		setup(_build)


func _on_build_downloaded() -> void:
	update()


func _on_delete_button_pressed() -> void:
	EngineBuildsManager.uninstall_build(_build)

func _on_download_button_pressed() -> void:
	Downloader.download(_build)
