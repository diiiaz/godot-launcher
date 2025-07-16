extends Control

#const CLOSE_WHILE_DOWNLOADING_POPUP_WINDOW_CONTENT = preload("res://scr/ui/popup_window/popup_windows_content/close_while_downloading_popup_window_content.tscn")
#@onready var main_pages_controller: Node = %MainPagesController
#@onready var projects_page: ProjectsPage = %ProjectsPage
#@onready var releases_page: ReleasesPage = %ReleasesPage
#@onready var settings_page: SettingsPage = %SettingsPage
@onready var loading_screen: CanvasLayer = %LoadingScreen


func _ready() -> void:
	BuildsManager.initialize()
	ProjectsManager.initialize()
	
	TranslationServer.set_locale(TranslationServer.get_loaded_locales()[SettingsManager.get_setting(Settings.SETTING.LANGUAGE)])
	
	#WARNING i don't know why but this lags the app when closing it. 
	SettingsManager.updated.connect(
		func(setting: Settings.SETTING) -> void:
			if setting != Settings.SETTING.LANGUAGE: return
			TranslationServer.set_locale(TranslationServer.get_loaded_locales()[SettingsManager.get_setting(Settings.SETTING.LANGUAGE)])
			TranslationServer.reload_pseudolocalization()
	)
	
	if not DirAccess.dir_exists_absolute(SettingsManager.get_setting_fallback_value(Settings.SETTING.PROJECTS_PATH)):
		DirAccess.make_dir_absolute(SettingsManager.get_setting_fallback_value(Settings.SETTING.PROJECTS_PATH))
	if not DirAccess.dir_exists_absolute(SettingsManager.get_setting_fallback_value(Settings.SETTING.BUILDS_PATH)):
		DirAccess.make_dir_absolute(SettingsManager.get_setting_fallback_value(Settings.SETTING.BUILDS_PATH))
	
	check_for_new_releases()
	get_tree().set_auto_accept_quit(false)
	
	#main_pages_controller.open_page(MainPagesController.PAGE.PROJECTS, false)
	loading_screen.close()


func check_for_new_releases() -> void:
	var current_time = Time.get_unix_time_from_system()
	
	var can_check_for_new_version: bool = \
		SettingsManager.get_setting(Settings.SETTING.CHECK_FOR_NEW_RELEASES_ON_STARTUP) and \
		(current_time - UserDataManager.get_user_data().check_new_version_timestamp) > TimeHelper.CHECK_NEW_VERSION_TIME_SEC
	
	if can_check_for_new_version:
		if not await ConnectionTester.is_connected_to_internet():
			return
		UserDataManager.set_user_data("check_new_version_timestamp", current_time)
		if not await BuildsFetcher.has_new_release():
			return
		ToastsManager.create_info_toast(TranslationServer.translate("TOAST_NEW_RELEASES"))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if BuildDownloader.is_downloading():
			#PopupWindowHelper.popup_window("CLOSE_APP", CLOSE_WHILE_DOWNLOADING_POPUP_WINDOW_CONTENT.instantiate(), get_viewport())
			return
		get_tree().quit()
