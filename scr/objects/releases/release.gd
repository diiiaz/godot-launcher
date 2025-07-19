extends RefCounted
class_name Release

signal build_downloaded
signal build_uninstalled

const INTERACTIVE_CHANGELOG_URL = "https://godotengine.github.io/godot-interactive-changelog/#{version}"
const HTML_URL = "https://github.com/godotengine/godot-builds/releases/tag/{version}"
const RELEASE_NAME_PLACEHOLDER = "{version}-{type}{type_version}"

var _version: String = "1.0"
var _type: ReleaseHelper.RELEASES_TYPE = ReleaseHelper.RELEASES_TYPE.STABLE
var _type_version: int = -1
var _builds: Array[EngineBuild] = []
var _published_at: int = 0


func set_version(version: String) -> Release:
	_version = version
	return self

func set_type(type: ReleaseHelper.RELEASES_TYPE) -> Release:
	_type = type
	return self

func set_type_version(type_version: int) -> Release:
	_type_version = type_version
	return self

func add_build(build: EngineBuild) -> Release:
	_builds.append(build)
	build.downloaded.connect(build_downloaded.emit)
	build.uninstalled.connect(build_uninstalled.emit)
	return self

func set_published_time(published_at: int) -> Release:
	_published_at = published_at
	return self


func get_version() -> String: return _version
func get_type() -> ReleaseHelper.RELEASES_TYPE: return _type
func get_type_version() -> int: return _type_version
func get_builds() -> Array[EngineBuild]: return _builds
func get_published_time() -> int: return _published_at
func get_downloaded_builds() -> Array: return _builds.filter(func(build: EngineBuild): return build.is_downloaded())


func get_name() -> String:
	var version_string: String = get_version()
	var type_string_value: String = ReleaseHelper.RELEASES_TYPE_NAMES.get(get_type())
	var type_version_string: String = str(get_type_version()) if get_type() != ReleaseHelper.RELEASES_TYPE.STABLE else ""
	return RELEASE_NAME_PLACEHOLDER.format({"version": version_string, "type": type_string_value, "type_version": type_version_string})


func get_tags() -> Array[String]:
	return [ReleaseHelper.RELEASES_TYPE_FORMATTED_NAME.get(get_type())]


func has_tags() -> bool:
	return not get_tags().is_empty()


func get_recommended_build() -> EngineBuild:
	var patterns: Array[String] = ReleaseHelper.get_release_patterns()
	
	for pattern: String in patterns:
		for build: EngineBuild in get_builds():
			if pattern not in build.get_url():
				continue
			if (build.is_mono()) != SettingsManager.get_setting(Settings.SETTING.USE_MONO_BUILDS):
				continue
			return build
	
	return null


func get_interactive_changelog_url() -> String:
	return INTERACTIVE_CHANGELOG_URL.format({"version": get_name()})

func get_html_url() -> String:
	return HTML_URL.format({"version": get_name()})


func get_formatted_name() -> String:
	var color: Color = Color(1, 1, 1, 0.6)
	var string: String = "[b]Godot v{version}[/b] [color={color}]{type} {type_version}[/color]".format({
		"color": color.to_html(true),
		"version": get_version(),
		"type": ReleaseHelper.RELEASES_TYPE_FORMATTED_NAME.get(get_type()),
		"type_version": str(get_type_version()) if get_type_version() != -1 else "",
	})
	return string
