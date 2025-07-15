extends RefCounted
class_name Build

# They are used but not in this class
@warning_ignore("unused_signal")
signal downloaded
@warning_ignore("unused_signal")
signal uninstalled

var _url: String = ""
var _platform: SystemHelper.PLATFORM = SystemHelper.PLATFORM.UNKNOWN
var _architecture: String = ""
var _is_mono: bool = false
var _size: float
var _tags: Array[String] = []

func _init(build_dict: Dictionary) -> void:
	set_url(build_dict.browser_download_url)
	set_platform(get_platform_from_url(get_url()))
	set_architecture(get_architecture_from_url(get_url()))
	set_mono_state(ReleaseHelper.MONO_KEY in get_url())
	set_size(build_dict.size)
	
	if not SystemHelper.PLATFORM_NAME.get(get_platform()).is_empty():
		_tags.append(SystemHelper.PLATFORM_NAME.get(get_platform()))
	
	if not get_architecture().is_empty():
		_tags.append(get_architecture())
	
	if is_mono():
		_tags.append("mono")


func set_url(url: String) -> Build:
	_url = url
	return self

func set_platform(platform: SystemHelper.PLATFORM) -> Build:
	_platform = platform
	return self

func set_architecture(architecture: String) -> Build:
	_architecture = architecture
	return self

func set_mono_state(state: bool) -> Build:
	_is_mono = state
	return self

func set_size(size: float) -> Build:
	_size = size
	return self


func get_url() -> String: return _url
func get_platform() -> SystemHelper.PLATFORM: return _platform
func get_architecture() -> String: return _architecture
func is_mono() -> bool: return _is_mono
func get_size() -> float: return _size
func get_name() -> String: return get_url().get_file()
func get_unextracted_path() -> String: return SettingsManager.get_setting(Settings.SETTING.BUILDS_PATH).path_join(get_name())
func get_path() -> String: return get_unextracted_path().replace(BuildDownloader.ZIP_EXTENSION, "")
func is_downloaded() -> bool: return FileAccess.file_exists(get_path())
func get_tags() -> Array[String]: return _tags

func get_version_name() -> String:
	var regex = RegEx.new()
	regex.compile("\\d+(?:\\.\\d+)*")
	var result = regex.search(get_name())
	return result.get_string() if result else ""


static func get_platform_from_url(url_string: String) -> SystemHelper.PLATFORM:
	for platform: SystemHelper.PLATFORM in SystemHelper.PLATFORM_URL_PATTERNS_MAPPING.keys():
		if SystemHelper.PLATFORM_URL_PATTERNS_MAPPING.values()[platform].any(func(url_pattern: String): return url_pattern in url_string):
			return platform
	return SystemHelper.PLATFORM.UNKNOWN


static func get_architecture_from_url(url_string: String) -> String:
	for platform: SystemHelper.PLATFORM in SystemHelper.PLATFORM_ARCHITECTURE_PATTERNS_MAPPING.keys():
		for architecture_pattern: String in SystemHelper.PLATFORM_ARCHITECTURE_PATTERNS_MAPPING.values()[platform]:
			if architecture_pattern in url_string:
				return architecture_pattern
	return ""
