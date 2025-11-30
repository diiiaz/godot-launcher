extends Node


static func copy_directory(source_path: String, dest_parent_path: String, new_name: String) -> int:
	var original_name = source_path.trim_suffix("/").get_file()
	var temp_dest_path = dest_parent_path.path_join(original_name)
	
	var copy_result = _recursive_copy_contents(source_path, temp_dest_path)
	if copy_result != OK:
		push_error("Copy failed with error code: %d" % copy_result)
		return copy_result
	
	var final_dest_path = dest_parent_path.path_join(new_name)
	var rename_result = DirAccess.rename_absolute(temp_dest_path, final_dest_path)
	
	if rename_result != OK:
		push_error("Rename failed with error code: %d" % rename_result)
	
	return rename_result


static func _recursive_copy_contents(source: String, destination: String) -> int:
	var dir = DirAccess.open(source)
	if dir == null:
		return ERR_CANT_OPEN
	
	# Ensure the destination folder (B) exists
	var err = DirAccess.make_dir_recursive_absolute(destination)
	if err != OK:
		return err
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
			
		var source_item = source.path_join(file_name)
		var dest_item = destination.path_join(file_name)
		
		if dir.current_is_dir():
			var res = _recursive_copy_contents(source_item, dest_item)
			if res != OK:
				return res
		else:
			var res = _copy_file_data(source_item, dest_item)
			if res != OK:
				return res
			
		file_name = dir.get_next()
	return OK


static func _copy_file_data(source_file: String, dest_file: String) -> int:
	var data = FileAccess.get_file_as_bytes(source_file)
	if data.is_empty() and not FileAccess.file_exists(source_file): return ERR_DOES_NOT_EXIST
	var file = FileAccess.open(dest_file, FileAccess.WRITE)
	if file == null:
		return ERR_CANT_OPEN
	file.store_buffer(data)
	return OK
