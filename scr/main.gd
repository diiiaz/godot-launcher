extends Control

const RELEASES_URL_TEMPLATE: String = "https://github.com/diiiaz/godot-launcher/releases/tag/{tag_name}"
const CLOSE_WHILE_DOWNLOADING_POPUP_WINDOW_CONTENT = preload("uid://b6rp7jwqchtvr")

@onready var loading_screen: CanvasLayer = %LoadingScreen
@onready var update_launcher_button: Button = %UpdateLauncherButton


func _ready() -> void:
	download_addon_to_user_path()
	create_latest_opened_launcher_path_file()
	
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


# ------------------------- hardcoded because idc right now

static func create_latest_opened_launcher_path_file() -> void:
	var file_path: String = UserDataManager.get_godot_launcher_user_path().path_join("latest_opened_launcher_path.json")
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string("{\"path\":\"{path}\"}".format({"path": OS.get_executable_path()}))
	file.close()


func download_addon_to_user_path() -> void:
	const TAG_NAME: String = "v1.0.1"
	var base_dir: String = UserDataManager.get_godot_launcher_user_path().path_join("addon")
	
	if DirAccess.dir_exists_absolute(base_dir) and not DirAccess.get_directories_at(base_dir).is_empty():
		return
	
	var file_path: String = base_dir.path_join("temp_file_name")
	
	if not DirAccess.dir_exists_absolute(base_dir):
		var err = DirAccess.make_dir_recursive_absolute(base_dir)
		if err != OK:
			push_error(error_string(err))
	
	await get_tree().process_frame
	
	if not await ConnectionTester.is_connected_to_internet():
		return
	
	var https_request: HTTPRequest = HTTPRequest.new()
	add_child(https_request)

	https_request.set_download_file(file_path)
	var request_error: Error = https_request.request("https://github.com/diiiaz/godot-launcher-addon/archive/refs/tags/{tag_name}.zip".format({"tag_name": TAG_NAME}))
	
	await https_request.request_completed
	https_request.queue_free()
	
	if request_error != OK:
		ToastsManager.create_error_toast(TranslationServer.translate("ERROR_REQUEST_FAILED").format({"error": request_error}))
		return
	
	Downloader.extract_all_from_zip(file_path)
