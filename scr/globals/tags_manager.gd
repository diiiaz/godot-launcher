extends Node

signal tag_group_changed(tag_group: TagGroup)

var _tag_groups: Dictionary[String, TagGroup]


func _init() -> void:
	load_tags()
	tag_group_changed.connect(func(_unused): save_tags.call_deferred())


func get_or_create_tag_group(group_name: String) -> TagGroup:
	if not _tag_groups.has(group_name):
		return _create_tag_group(group_name)
	return _tag_groups.get(group_name)

func _create_tag_group(group_name: String) -> TagGroup:
	if _tag_groups.has(group_name):
		ToastsManager.create_error_toast("Tags Group \"%s\" already exist. (tags_manager.gd::create_tag_group)")
		return null
	var new_tag_group: TagGroup = TagGroup.new(group_name)
	_tag_groups[group_name] = new_tag_group
	new_tag_group.added_tag.connect(func(_unused): tag_group_changed.emit(new_tag_group))
	new_tag_group.deleted_tag.connect(func(_unused): tag_group_changed.emit(new_tag_group))
	new_tag_group.renamed_tag.connect(func(_unused0, _unused1): tag_group_changed.emit(new_tag_group))
	new_tag_group.cleared.connect(func(_unused): tag_group_changed.emit(new_tag_group))
	return new_tag_group


func save_tags() -> void:
	var tags: Dictionary[String, Array]
	for tag_group: TagGroup in _tag_groups.values():
		tags[tag_group.get_group_name()] = []
		for tag: Tag in tag_group.get_tags():
			tags[tag_group.get_group_name()].append(tag.get_name())
	UserDataManager.set_user_data(UserData.USER_DATA.TAGS, tags)

func load_tags() -> void:
	_tag_groups.clear()
	var tags: Dictionary[String, Array] = UserDataManager.get_user_data(UserData.USER_DATA.TAGS)
	for index: int in tags.size():
		var tag_group_name: String = tags.keys()[index]
		var tags_name: Array[String] = []
		tags_name.assign(tags[tag_group_name])
		get_or_create_tag_group(tag_group_name).create_tags(tags_name)
