extends Node
#class_name LauncherBuildsFetcher

const REMOTE_API_RELEASES_URL = "https://api.github.com/repos/diiiaz/godot-launcher/releases"

var _next_version_release: Dictionary


func get_latest_version() -> String:
	return _next_version_release.tag_name

# We cannot update the launcher if run via editor,
# because we use: OS.get_executable_path(), that return the Godot Editor .exe instead of the Godot Launcher .exe in editor mode
func can_update() -> bool:
	return not OS.has_feature("editor") 

func has_new_release() -> bool:
	return not _next_version_release.is_empty()

func get_version() -> String:
	return ProjectSettings.get_setting("application/config/version", "1.0.0")

# Convert a version number to an actually comparable number
func version_to_number(version: String) -> int:
	var bits = version.split(".")
	return bits[0].to_int() * 1000000 + bits[1].to_int() * 1000 + bits[2].to_int()


func check_for_update() -> void:
	if not can_update(): return
	var http_request: HTTPRequest = HTTPRequest.new()
	http_request.request_completed.connect(_on_http_request_check_request_completed, CONNECT_ONE_SHOT)
	http_request.ready.connect(func(): http_request.request(REMOTE_API_RELEASES_URL))
	add_child(http_request)
	await http_request.request_completed


func _on_http_request_check_request_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS: return
	
	var current_version: String = get_version()
	
	# Work out the next version from the releases information on GitHub
	var response = JSON.parse_string(body.get_string_from_utf8())
	if typeof(response) != TYPE_ARRAY: return

	# GitHub releases are in order of creation, not order of version
	var versions = (response as Array).filter(func(release):
		var version: String = release.tag_name
		#prints(version_to_number(version), version_to_number(current_version))
		return version_to_number(version) > version_to_number(current_version)
	)
	if versions.size() > 0:
		_next_version_release = versions[0]
