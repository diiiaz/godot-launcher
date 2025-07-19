extends RefCounted
class_name ReleaseHelper

const MONO_KEY = "mono"

enum RELEASES_TYPE {
	STABLE,
	RC, # Release Candidate
	BETA,
	ALPHA,
	DEV,
}

const RELEASES_TYPE_NAMES = {
	RELEASES_TYPE.STABLE: "stable",
	RELEASES_TYPE.RC: "rc",
	RELEASES_TYPE.BETA: "beta",
	RELEASES_TYPE.ALPHA: "alpha",
	RELEASES_TYPE.DEV: "dev",
}

const RELEASES_TYPE_FORMATTED_NAME = {
	RELEASES_TYPE.STABLE: "Stable",
	RELEASES_TYPE.RC: "Release Candidate",
	RELEASES_TYPE.BETA: "Beta",
	RELEASES_TYPE.ALPHA: "Alpha",
	RELEASES_TYPE.DEV: "Dev",
}


#region x---------------------------------------x Patterns

static func get_release_patterns() -> Array[String]:
	var system: SystemInfo = SystemHelper.get_or_create_system_info()
	var patterns: Array[String] = []
	
	match system.get_platform():
		SystemHelper.PLATFORM.WINDOWS:
			patterns = get_windows_patterns()
		
		SystemHelper.PLATFORM.MACOS:
			patterns = get_macos_patterns()
		
		SystemHelper.PLATFORM.LINUX:
			patterns = get_linux_patterns()
	
	return patterns


static func get_windows_patterns() -> Array[String]:
	var system: SystemInfo = SystemHelper.get_or_create_system_info()
	var arch = ""
	match system.get_architecture():
		"x86_64": arch = "win64"
		"x86": arch = "win32"
		"arm64": arch = "windows_arm64"
	
	return [
		"mono_{architecture}.".format({"architecture": arch}),
		"{architecture}.".format({"architecture": arch})
	]


static func get_linux_patterns() -> Array[String]:
	var system: SystemInfo = SystemHelper.get_or_create_system_info()
	var arch = ""
	match system.get_architecture():
		"x86_64": arch = "x86_64"
		"x86": arch = "x86_32"
		"arm64": arch = "arm64"
		"armv7": arch = "arm32"
	
	return [
		"mono_linux_{architecture}.".format({"architecture": arch}),
		"linux.{architecture}.".format({"architecture": arch})
	]


static func get_macos_patterns() -> Array[String]:
	return [
		"mono_macos.universal.",
		"macos.universal."
	]

#endregion


#region x---------------------------------------x Dictionnary Converter

static func get_version_from_release_dict(release_dict: Dictionary) -> String:
	var name: String = get_name_from_release_dict(release_dict)
	
	var regex: RegEx = RegEx.create_from_string("^[0-9.]+(?=-)")
	var regex_match: RegExMatch = regex.search(name)
	
	if regex_match == null or regex_match.strings.is_empty():
		push_error("No version found in '%s'." % [name])
		return ""
	
	return regex_match.strings[0]


static func get_type_from_release_dict(release_dict: Dictionary) -> RELEASES_TYPE:
	var name: String = get_name_from_release_dict(release_dict)
	for release_type: RELEASES_TYPE in RELEASES_TYPE.values():
		if RELEASES_TYPE_NAMES.get(release_type) in name:
			return release_type
	push_error("No release type found in '%s'" % [name])
	@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
	return -1


static func get_type_version_from_release_dict(release_dict: Dictionary) -> int:
	var name: String = get_name_from_release_dict(release_dict)
	# if we are a stable release no need for a type version number
	if RELEASES_TYPE_NAMES.get(RELEASES_TYPE.STABLE) in name:
		return -1
	
	var regex: RegEx = RegEx.create_from_string("(-?\\d+)(?!.*\\d)")
	var regex_match: RegExMatch = regex.search(name)
	
	if regex_match == null or regex_match.strings.is_empty() or not regex_match.strings[0].is_valid_int():
		push_error("No release type version found in '%s'." % [name])
		return -1
	
	return regex_match.strings[0].to_int()

static func get_name_from_release_dict(release_dict: Dictionary) -> String:
	return release_dict.html_url.split("/")[-1]

#endregion
