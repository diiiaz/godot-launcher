extends RefCounted
class_name TagsGroup

signal tags_changed(tags: PackedStringArray)

var _tags: PackedStringArray


func add_tag(tag_name: String) -> TagsGroup:
	if tag_exist(tag_name):
		return
	_tags.append(tag_name)
	_tags.sort()
	tags_changed.emit(_tags)
	return self


func add_tags(tags_name: PackedStringArray) -> TagsGroup:
	for tag_name: String in tags_name:
		add_tag(tag_name)
	return self


func tag_exist(tag_name: String) -> bool:
	return _tags.has(tag_name)


func get_tags() -> PackedStringArray:
	return _tags


func clear() -> void:
	_tags.clear()
