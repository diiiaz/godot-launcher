extends Downloadable
class_name DownloadableBuild

var _platform: SystemHelper.PLATFORM = SystemHelper.PLATFORM.UNKNOWN
var _architecture: String = ""
var _is_mono: bool = false


func _init(build_dict: Dictionary, file_path: String) -> void:
	super._init(build_dict, file_path)
	set_platform(get_platform_from_url(get_url()))
	set_architecture(get_architecture_from_url(get_url()))
	set_mono_state(ReleaseHelper.MONO_KEY in get_url())


func set_platform(platform: SystemHelper.PLATFORM) -> DownloadableBuild:
	_platform = platform
	return self

func set_architecture(architecture: String) -> DownloadableBuild:
	_architecture = architecture
	return self

func set_mono_state(state: bool) -> DownloadableBuild:
	_is_mono = state
	return self


func get_platform() -> SystemHelper.PLATFORM: return _platform
func get_architecture() -> String: return _architecture
func is_mono() -> bool: return _is_mono


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

func get_version_name() -> String:
	var regex = RegEx.new()
	regex.compile("\\d+(?:\\.\\d+)*")
	var result = regex.search(get_name())
	return result.get_string() if result else ""
