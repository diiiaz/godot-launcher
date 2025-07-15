extends RefCounted
class_name SystemInfo

var _platform: SystemHelper.PLATFORM
var _arch: String


func _init(platform: SystemHelper.PLATFORM, arch: String) -> void:
	_platform = platform
	_arch = arch


func get_platform() -> SystemHelper.PLATFORM:
	return _platform

func get_architecture() -> String:
	return _arch
