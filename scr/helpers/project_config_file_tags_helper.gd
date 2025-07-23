extends RefCounted
class_name ProjectConfigFileTagsHelper


const TAGS_REGEX_PATTERN = "(config/tags\\s*=\\s*PackedStringArray\\()([^)]*)(\\))"


# ---------------------------------------------- Main Functions ----------------------------------------------

static func add_tag(project: Project, tag_name: String) -> void:
	if has_tag(project, tag_name):
		return
	
	var content := _read_file_content(project)
	if content.is_empty(): return

	var regex := RegEx.create_from_string(TAGS_REGEX_PATTERN)
	var tag_added := false
	var new_content := ""
	var last_end := 0

	for match_result in regex.search_all(content):
		var prefix = match_result.get_string(1)
		var tags_str = match_result.get_string(2)
		var suffix = match_result.get_string(3)
		
		var tags = _parse_tags(tags_str)
		if not tag_name in tags:
			tags.append(tag_name)
			tag_added = true
		
		new_content += content.substr(last_end, match_result.get_start() - last_end)
		new_content += prefix + _format_tags(tags) + suffix
		last_end = match_result.get_end()
	
	if not tag_added:
		content = _add_new_tag_line(content, tag_name)
	else:
		new_content += content.substr(last_end)
		content = new_content
	_write_file_content(project, content)


static func remove_tag(project: Project, tag_name: String) -> void:
	if not has_tag(project, tag_name):
		return
	
	var content := _read_file_content(project)
	if content.is_empty(): return

	var regex := RegEx.create_from_string(TAGS_REGEX_PATTERN)
	var new_content := ""
	var last_end := 0
	var modified := false

	for match_result in regex.search_all(content):
		modified = true
		var prefix = match_result.get_string(1)
		var tags_str = match_result.get_string(2)
		var suffix = match_result.get_string(3)
		
		var tags = _parse_tags(tags_str)
		tags = tags.filter(func(tag): return tag != tag_name)
		
		new_content += content.substr(last_end, match_result.get_start() - last_end)
		new_content += prefix + _format_tags(tags) + suffix
		last_end = match_result.get_end()
	
	new_content += content.substr(last_end)
	_write_file_content(project, new_content if modified else content)


static func has_tag(project: Project, tag_name: String) -> bool:
	var content := _read_file_content(project)
	if content.is_empty(): return false
	
	var regex := RegEx.create_from_string(TAGS_REGEX_PATTERN)
	
	for match_result in regex.search_all(content):
		var tags_str = match_result.get_string(2)  # Get the tag list content
		var tags = _parse_tags(tags_str)
		if tag_name in tags:
			return true
	
	return false


static func rename_tag(project: Project, tag_name: String, new_tag_name: String) -> void:
	var content := _read_file_content(project)
	if content.is_empty(): return

	var regex := RegEx.create_from_string(TAGS_REGEX_PATTERN)
	var new_content := ""
	var last_end := 0
	var modified := false

	for match_result in regex.search_all(content):
		modified = true
		var prefix = match_result.get_string(1)
		var tags_str = match_result.get_string(2)
		var suffix = match_result.get_string(3)
		
		var tags = _parse_tags(tags_str)
		var renamed := false
		
		# Replace all occurrences of the old tag with the new one
		for i in range(tags.size()):
			if tags[i] == tag_name:
				tags[i] = new_tag_name
				renamed = true
		
		# Remove duplicates if we renamed a tag
		if renamed:
			tags = _remove_duplicates(tags)
		
		new_content += content.substr(last_end, match_result.get_start() - last_end)
		new_content += prefix + _format_tags(tags) + suffix
		last_end = match_result.get_end()
	
	new_content += content.substr(last_end)
	
	if modified:
		_write_file_content(project, new_content)
	else:
		push_error("Tag '" + tag_name + "' not found in config")


# ---------------------------------------------- Helpers ----------------------------------------------

static func _read_file_content(project: Project) -> String:
	var file := FileAccess.open(project.get_config_file_path(), FileAccess.READ)
	if not file:
		push_error("Failed to open file: " + project.get_config_file_path())
		return ""
	var content := file.get_as_text()
	file.close()
	return content


static func _write_file_content(project: Project, content: String) -> void:
	var file := FileAccess.open(project.get_config_file_path(), FileAccess.WRITE)
	if not file:
		push_error("Failed to write file: " + project.get_config_file_path())
		return
	file.store_string(content)
	file.close()


static func _parse_tags(tags_str: String) -> Array[String]:
	var tags: Array[String] = []
	for tag in tags_str.split(","):
		var clean = tag.strip_edges().trim_prefix('"').trim_suffix('"')
		if not clean.is_empty(): tags.append(clean)
	return tags


static func _format_tags(tags: Array[String]) -> String:
	return ", ".join(tags.map(func(tag): return '"' + tag + '"'))


static func _add_new_tag_line(content: String, tag: String) -> String:
	var section_header: String = "[application]"
	var section_idx:= content.find(section_header)
	
	if section_idx == -1:
		return content + "\n\n[application]\nconfig/tags=PackedStringArray(\"" + tag + "\")"
	
	var section_end := content.find("\n[", section_idx)
	if section_end == -1: section_end = content.length()
	
	var before := content.substr(0, section_end).strip_edges()
	var after := content.substr(section_end)
	var new_line := "\nconfig/tags=PackedStringArray(\"" + tag + "\")"
	
	return before + ("" if before.ends_with("\n") else "\n") + new_line + after


static func _remove_duplicates(tags: Array[String]) -> Array[String]:
	var unique: Array[String] = []
	for tag in tags:
		if not tag in unique:
			unique.append(tag)
	return unique
