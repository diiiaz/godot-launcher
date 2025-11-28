extends Control

const RELEASES_URL_TEMPLATE: String = "https://github.com/diiiaz/godot-launcher/releases/tag/{tag_name}"
const CLOSE_WHILE_DOWNLOADING_POPUP_WINDOW_CONTENT = preload("uid://b6rp7jwqchtvr")

@onready var loading_screen: CanvasLayer = %LoadingScreen
@onready var update_launcher_button: Button = %UpdateLauncherButton


func _ready() -> void:
	if SettingsManager.get_setting(Settings.SETTING.CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP) or SettingsManager.get_setting(Settings.SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP):
		ConnectionTester.is_connected_to_internet(true)
	
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
	
	EngineBuildsManager.initialize()
	ProjectsManager.initialize()
	update_launcher_button.text = "v" + ProjectSettings.get_setting("application/config/version")
	
	if SettingsManager.get_setting(Settings.SETTING.CHECK_FOR_NEW_LAUNCHER_RELEASES_ON_STARTUP):
		check_for_new_launcher_releases()
	if SettingsManager.get_setting(Settings.SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP):
		check_for_new_engine_releases()
	get_tree().set_auto_accept_quit(false)
	
	loading_screen.close()


func check_for_new_launcher_releases() -> void:
	if not await ConnectionTester.is_connected_to_internet():
		return
	await LauncherBuildsFetcher.check_for_update()
	if LauncherBuildsFetcher.has_new_release():
		ToastsManager.create_info_toast(TranslationServer.translate("TOAST_NEW_LAUNCHER_RELEASES"))


func _on_update_launcher_button_pressed() -> void:
	if LauncherBuildsFetcher.has_new_release():
		OS.shell_open(RELEASES_URL_TEMPLATE.format({"tag_name": LauncherBuildsFetcher.get_latest_version()}))
	else:
		if not await ConnectionTester.is_connected_to_internet(true):
			return
		await check_for_new_launcher_releases()
		if not LauncherBuildsFetcher.has_new_release():
			ToastsManager.create_info_toast(TranslationServer.translate("TOAST_NO_NEW_LAUNCHER_RELEASES"))


func check_for_new_engine_releases() -> void:
	if not await ConnectionTester.is_connected_to_internet():
		return
	
	var current_time = Time.get_unix_time_from_system()
	
	var can_check_for_new_release: bool = \
		SettingsManager.get_setting(Settings.SETTING.CHECK_FOR_NEW_ENGINE_RELEASES_ON_STARTUP) and \
		(current_time - UserDataManager.get_user_data(UserData.USER_DATA.CHECK_NEW_VERSION_TIMESTAMP)) > TimeHelper.CHECK_NEW_VERSION_TIME_SEC
	
	if not can_check_for_new_release:
		return
	
	UserDataManager.set_user_data(UserData.USER_DATA.CHECK_NEW_VERSION_TIMESTAMP, current_time)
	
	if await EngineBuildsFetcher.has_new_release():
		ToastsManager.create_info_toast(TranslationServer.translate("TOAST_NEW_BUILD_RELEASES"))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if Downloader.is_downloading():
			var popup_content: CloseWhileDownlaodingPopupWindowContent = CLOSE_WHILE_DOWNLOADING_POPUP_WINDOW_CONTENT.instantiate()
			popup_content.user_input_result.connect(_on_close_while_downloading_popup_content_user_input)
			PopupWindowHelper.popup_window("CLOSE_APP", popup_content, get_viewport())
			return
		get_tree().quit()

func _on_close_while_downloading_popup_content_user_input(result: PopupWindowContent.Result) -> void:
	if result.action_is_close():
		get_tree().quit()
