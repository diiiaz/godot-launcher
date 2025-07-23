@tool
@abstract
extends Node
class_name Component

var _parent: Node

@abstract func parent_is_correct(__parent: Node) -> bool
@abstract func uncorrect_parent_error_message(__parent: Node) -> String
@abstract func get_component_name() -> String

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not parent_is_correct(get_parent()):
		warnings.append(uncorrect_parent_error_message(get_parent()))
		return warnings
	return warnings


func _ready() -> void:
	if Engine.is_editor_hint():
		_parent = get_parent()
		return
	assert(parent_is_correct(get_parent()), uncorrect_parent_error_message(get_parent()))
	_parent = get_parent()
