extends RefCounted
class_name Tag

var _name: String = ""


func _init(name: String) -> void:
	_name = name


func set_name(new_name: String) -> void:
	_name = new_name


func get_name() -> String: return _name
func get_hue() -> float: return float(wrapi(hash(_name), 0, 10000) / 10000.0)


func _to_string() -> String:
	return "Tag.to_string::\"{tag_name}\"".format({"tag_name": _name})
