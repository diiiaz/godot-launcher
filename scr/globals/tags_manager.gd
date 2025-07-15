extends Node

var _tags_groups: Dictionary[String, TagsGroup]


func create_tags_group(group_name: String, tags: Array[String] = []) -> TagsGroup:
	if _tags_groups.has(group_name):
		ToastsManager.create_error_toast("Tags Group \"%s\" already exist. (tags_manager.gd::create_tags_group)")
		return null
	_tags_groups[group_name] = TagsGroup.new().add_tags(tags)
	return _tags_groups[group_name]


func get_tags_group(group_name: String) -> TagsGroup:
	if not _tags_groups.has(group_name):
		return create_tags_group(group_name)
	return _tags_groups.get(group_name)


#signal tags_changed(tags: PackedStringArray)
#
#var _tags: PackedStringArray
#
#
#func add_tag(tag_name: String) -> void:
	#if tag_exist(tag_name):
		#return
	#_tags.append(tag_name)
	#_tags.sort()
	#tags_changed.emit(_tags)
#
#
#func add_tags(tags_name: PackedStringArray) -> void:
	#for tag_name: String in tags_name:
		#add_tag(tag_name)
#
#
#func tag_exist(tag_name: String) -> bool:
	#return _tags.has(tag_name)
#
#
#func get_tags() -> PackedStringArray:
	#return _tags
#
#
#func clear() -> void:
	#_tags.clear()
