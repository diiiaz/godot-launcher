extends Control

const CLOSE_WHILE_DOWNLOADING_POPUP_WINDOW_CONTENT = preload("uid://b6rp7jwqchtvr")

@onready var loading_screen: CanvasLayer = %LoadingScreen


func _ready() -> void:
	BuildsManager.initialize()
	ProjectsManager.initialize()
	
	TranslationServer.set_locale(TranslationServer.get_loaded_locales()[SettingsManager.get_setting(Settings.SETTING.LANGUAGE)])
	
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
	
	loading_screen.close()


func check_for_new_releases() -> void:
	var current_time = Time.get_unix_time_from_system()
	
	var can_check_for_new_version: bool = \
		SettingsManager.get_setting(Settings.SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP) and \
		(current_time - UserDataManager.get_user_data(UserData.USER_DATA.CHECK_NEW_VERSION_TIMESTAMP)) > TimeHelper.CHECK_NEW_VERSION_TIME_SEC
	
	if can_check_for_new_version:
		if not await ConnectionTester.is_connected_to_internet():
			return
		UserDataManager.set_user_data(UserData.USER_DATA.CHECK_NEW_VERSION_TIMESTAMP, current_time)
		if not await BuildsFetcher.has_new_release():
			return
		ToastsManager.create_info_toast(TranslationServer.translate("TOAST_NEW_RELEASES"))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if BuildDownloader.is_downloading():
			var popup_content: CloseWhileDownlaodingPopupWindowContent = CLOSE_WHILE_DOWNLOADING_POPUP_WINDOW_CONTENT.instantiate()
			popup_content.user_input_result.connect(_on_close_while_downloading_popup_content_user_input)
			PopupWindowHelper.popup_window("CLOSE_APP", popup_content, get_viewport())
			return
		get_tree().quit()

func _on_close_while_downloading_popup_content_user_input(result: PopupWindowContent.Result) -> void:
	if result.action_is_close():
		get_tree().quit()
