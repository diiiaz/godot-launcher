extends DownloadableBuild
class_name EngineBuild

var _tags: Array[String] = []


func _init(build_dict: Dictionary) -> void:
	super._init(build_dict, SettingsManager.get_setting(Settings.SETTING.BUILDS_PATH).path_join(build_dict.browser_download_url.get_file()))
	
	if not SystemHelper.PLATFORM_NAME.get(get_platform()).is_empty():
		_tags.append(SystemHelper.PLATFORM_NAME.get(get_platform()))
	
	if not get_architecture().is_empty():
		_tags.append(get_architecture())
	
	if is_mono():
		_tags.append("mono")


func get_tags() -> Array[String]: return _tags
