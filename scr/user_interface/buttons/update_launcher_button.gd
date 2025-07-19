extends Button

func _ready() -> void:
	check_for_new_launcher_releases()


func check_for_new_launcher_releases() -> void:
	if not await ConnectionTester.is_connected_to_internet():
		return
	await LauncherBuildsFetcher.check_for_update()
	var new_launcher_release_available: bool = LauncherBuildsFetcher.has_new_release()
	if new_launcher_release_available:
		text = "v" + LauncherBuildsFetcher.get_latest_version()
		tooltip_text = "TOOLTIP_DOWNLOAD_LATEST_LAUNCHER_RELEASE"
		add_theme_color_override("font_color", ColorHelper.LIGHT_GREEN * 1.2)
		add_theme_color_override("font_hover_color", ColorHelper.LIGHT_GREEN * 1.2)
		add_theme_color_override("font_focus_color", ColorHelper.LIGHT_GREEN * 1.2)
	else:
		tooltip_text = "TOOLTIP_CHECK_NEW_LAUNCHER_RELEASE"
		remove_theme_color_override("font_color")
		remove_theme_color_override("font_hover_color")
		remove_theme_color_override("font_focus_color")
