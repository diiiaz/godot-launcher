extends Node

const API_URL = "https://api.github.com/repos/godotengine/godot-builds/releases?per_page=100&page=%d"
const LATEST_API_URL = "https://api.github.com/repos/godotengine/godot-builds/releases?per_page=1&page=1"
const CACHE_PATH = "user://releases_cache.json"
const CACHE_EXPIRY_SEC = 7 * 24 * 60 * 60  # 1 week

const DENIED_BUILDS_NAMES = [
	"template",
	"android",
	"editor",
	"export",
	".txt",
	".tar",
	".aar",
]

const ACCEPTED_RELEASE_DICT_NAMES = [
	"assets",
	"html_url",
	"published_at",
]

const ACCEPTED_BUILD_DICT_NAMES = [
	"browser_download_url",
	"size",
]

var _instance_cached_data: Dictionary


#region x-------------------------------x Public


func has_new_release() -> bool:
	var latest_release: Dictionary = await get_latest_release()
	if latest_release.is_empty():
		return false
	return true


# returns non-empty only if there is a new release else its just empty.
func get_latest_release() -> Dictionary:
	var releases: Array = await fetch_or_load_releases()
	
	if releases.is_empty():
		return {}
	
	var latest_release: Dictionary = await fetch_latest_release()
	if latest_release.is_empty():
		return {}
	
	if (TimeHelper.convert_iso_to_unix_time(latest_release.published_at) - TimeHelper.convert_iso_to_unix_time(releases[0].published_at)) < 10:
		return {}
	
	return latest_release


func fetch_latest_release() -> Dictionary:
	var releases: Array = await _fetch_github_api(LATEST_API_URL)
	if releases.is_empty():
		return {}
	return releases[0]


func fetch_or_load_releases(force_fetch: bool = false) -> Array:
	var cached_data: Dictionary = _get_cached_data()
	
	if not cached_data.is_empty() and not _is_cache_expired(cached_data) and not force_fetch:
		return cached_data.releases
	else:
		var current_page: int = 1
		var all_releases: Array = []
		while true:
			# Fetch the current page
			var releases: Array = await _fetch_github_api(API_URL % current_page)
			
			# Stop if no more releases
			if releases.is_empty():
				break
			
			# Add releases to the list
			all_releases += releases
			current_page += 1
		
		if all_releases.is_empty():
			return []
		
		return _save_cache(all_releases)

#endregion


#region x-------------------------------x Private 


func _get_cached_data() -> Dictionary:
	if _instance_cached_data.is_empty():
		_instance_cached_data = _load_cache()
	return _instance_cached_data


func _fetch_github_api(url: String) -> Array:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request(url)
	
	var result = await http_request.request_completed
	http_request.queue_free()
	
	if result[0] != HTTPRequest.RESULT_SUCCESS:
		return []
	
	var json = JSON.new()
	json.parse(result[3].get_string_from_utf8())
	
	if json.get_data().has("message"):
		if "rate" in json.get_data().message:
			ToastsManager.create_error_toast(TranslationServer.translate("ERROR_API_RATE_LIMIT_EXCEEDED"))
			return []
	
	return json.get_data() if json.get_data() != null else []


# Load cached data if valid
func _load_cache() -> Dictionary:
	if not FileAccess.file_exists(CACHE_PATH):
		return {}
	var file = FileAccess.open(CACHE_PATH, FileAccess.READ)
	var cached_data = JSON.parse_string(file.get_as_text())
	file.close()
	return cached_data


# Save with timestamp
func _save_cache(data_to_save: Array) -> Array[Dictionary]:
	var saved_data: Array[Dictionary] = []
	
	for release_data in data_to_save:
		saved_data.append({})
		for data in release_data:
			if not ACCEPTED_RELEASE_DICT_NAMES.any(func(accepted_release_dict_name: String): return data == accepted_release_dict_name):
				continue
			if data == "assets":
				saved_data[-1][data] = []
				for build: Dictionary in release_data[data]:
					if DENIED_BUILDS_NAMES.any(func(denied_build_name: String): return denied_build_name in build.name):
						continue
					saved_data[-1][data].append({})
					for build_data in build:
						if not ACCEPTED_BUILD_DICT_NAMES.any(func(accepted_build_dict_name: String): return build_data == accepted_build_dict_name):
							continue
						saved_data[-1][data][-1][build_data] = build.get(build_data)
			else:
				saved_data[-1][data] = release_data[data]
	
	var cache: Dictionary = {
		"timestamp": Time.get_unix_time_from_system(),
		"releases": saved_data
	}
	
	var file: FileAccess = FileAccess.open(CACHE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(cache))
	file.close()
	return saved_data


# Check if cache expired
func _is_cache_expired(cached_data) -> bool:
	var current_time = Time.get_unix_time_from_system()
	return (current_time - cached_data.timestamp) > CACHE_EXPIRY_SEC


func _fallback_build(builds: Array[Build], os_key: String) -> Build:
	var is_mono: bool = SettingsManager.get_setting(Settings.SETTING.USE_MONO_BUILDS)
	var fallback_patterns = []
	var mono_prefix = "_mono_" if is_mono else ""
	match os_key:
		"win":
			var extension = ".zip" if is_mono else ".exe"
			fallback_patterns.append("%s%s64%s" % [mono_prefix, os_key, extension])
			fallback_patterns.append("%s%s32%s" % [mono_prefix, os_key, extension])
		"linux":
			fallback_patterns.append("%slinux.x86_64" % mono_prefix)
			fallback_patterns.append("%slinux.x86_32" % mono_prefix)
		"macos":
			fallback_patterns.append("%smacos.universal" % mono_prefix)

	for pattern in fallback_patterns:
		for build: Build in builds:
			if build["name"].find(pattern) != -1:
				return build["download_url"]

	return null

#endregion
