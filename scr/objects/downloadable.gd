extends RefCounted
class_name Downloadable

# They are used but not in this class
@warning_ignore("unused_signal")
signal downloaded
@warning_ignore("unused_signal")
signal uninstalled

var _url: String = ""
var _file_path: String = ""
var _size: float

func _init(build_dict: Dictionary, file_path: String) -> void:
	set_url(build_dict.browser_download_url)
	set_size(build_dict.size)
	set_file_path(file_path)


func set_url(url: String) -> Downloadable:
	_url = url
	return self

func set_file_path(file_path: String) -> Downloadable:
	_file_path = file_path
	return self

func set_size(size: float) -> Downloadable:
	_size = size
	return self


func get_url() -> String: return _url
func get_size() -> float: return _size
func get_name() -> String: return get_url().get_file()
func get_unextracted_path() -> String: return _file_path
func get_path() -> String: return get_unextracted_path().replace(Downloader.ZIP_EXTENSION, "")
func is_downloaded() -> bool: return FileAccess.file_exists(get_path())
