extends OptionButton
class_name BuildOptionbutton

signal selected_build(build: EngineBuild)


func _ready() -> void:
	EngineBuildsManager.downloaded_build.connect(func(_build: EngineBuild): update())
	EngineBuildsManager.uninstalled_build.connect(func(_build: EngineBuild): update())
	get_popup().about_to_popup.connect(_on_about_to_popup)
	item_selected.connect(_on_item_selected)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		update()


func _on_about_to_popup() -> void:
	get_popup().theme_type_variation = "DefaultPopupMenu"


func update() -> void:
	clear()
	
	disabled = not EngineBuildsManager.has_downloaded_builds()
	if EngineBuildsManager.has_downloaded_builds():
		add_item(tr("NO_BUILD_SELECTED"), 0)
		set_item_disabled(0, true)
		add_separator(tr("SELECT_BUILD"))
		
		var index: int = 2
		for build: EngineBuild in EngineBuildsManager.get_downloaded_builds():
			add_item(build.get_path().get_file())
			set_item_metadata(index, build)
			index += 1
	else:
		add_item(tr("NO_BUILDS_AVAILABLE"))
	
	select(0)

func _on_item_selected(index: int) -> void:
	selected_build.emit(get_item_metadata(index))
