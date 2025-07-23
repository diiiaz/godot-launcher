extends RefCounted
class_name TagGroup

signal added_tag(tag: Tag)
signal deleted_tag(tag: Tag)
signal renamed_tag(tag: Tag, old_name: String)
signal cleared

var _group_name: String
var _tags: Array[Tag]


func _init(group_name: String) -> void:
	_group_name = group_name


func create_tag(tag_name: String) -> Tag:
	if has_tag_name(tag_name):
		return get_tag(tag_name)
	var tag: Tag = Tag.new(tag_name)
	add_tag(tag)
	return tag

func create_tags(tags_name: Array[String]) -> TagGroup:
	for tag_name: String in tags_name:
		create_tag(tag_name)
	return self


func get_or_create_tag(tag_name: String) -> Tag:
	if has_tag_name(tag_name):
		return get_tag(tag_name)
	return create_tag(tag_name)


func add_tag(tag: Tag) -> TagGroup:
	if has_tag_name(tag.get_name()):
		return self
	_tags.append(tag)
	sort_tags()
	added_tag.emit(tag)
	return self

func add_tags(tags: Array[Tag]) -> TagGroup:
	for tag: Tag in tags:
		add_tag(tag)
	return self


func delete_tag(tag: Tag) -> TagGroup:
	if not has_tag(tag):
		return self
	_tags.erase(tag)
	sort_tags()
	deleted_tag.emit(tag)
	return self


func rename_tag(tag: Tag, new_name: String) -> void:
	if not has_tag(tag):
		return
	var old_name: String = tag.get_name()
	tag.set_name(new_name)
	sort_tags()
	renamed_tag.emit(tag, old_name)


func sort_tags() -> void:
	_tags.sort_custom(func(a: Tag, b: Tag): return a.get_name() < b.get_name())


func clear() -> void:
	_tags.clear()
	cleared.emit()


func has_tag(tag: Tag) -> bool:
	return _tags.has(tag)

func has_tag_name(tag_name: String) -> bool:
	return _tags.any(func(tag: Tag): return tag_name == tag.get_name())


func get_tags() -> Array[Tag]:
	return _tags

func get_tag(tag_name: String) -> Tag:
	if not has_tag_name(tag_name):
		return null
	var tags: Array = _tags.filter(func(tag: Tag): return tag_name == tag.get_name())
	if tags.is_empty():
		return null
	return tags[0]


func get_group_name() -> String: return _group_name


func _to_string() -> String:
	return "TagGroup.to_string::\"{tag_group}\": {tags_names}".format({"tag_group": _group_name, "tags_names": _tags})
