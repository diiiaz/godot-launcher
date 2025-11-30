extends Node

static func copy_directory(source_dir: String, dest_dir: String) -> int:
	var dir = DirAccess.open(source_dir)
	if dir == null:
		push_error("DirAccess Helper Error: Could not open source directory: %s" % source_dir)
		return ERR_CANT_OPEN
	
	var error = DirAccess.make_dir_recursive_absolute(dest_dir)
	if error != OK:
		push_error("DirAccess Helper Error: Could not create destination directory: %s (Error: %d)" % [dest_dir, error])
		return error
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue
			
		var source_path = source_dir.path_join(file_name)
		var dest_path = dest_dir.path_join(file_name)
		
		if dir.current_is_dir():
			var result = copy_directory(source_path, dest_path)
			if result != OK:
				dir.list_dir_end()
				return result
		else:
			var result = copy_file(source_path, dest_path)
			if result != OK:
				dir.list_dir_end()
				return result
		
		file_name = dir.get_next()
		
	dir.list_dir_end()
	return OK


# Helper function to copy a single file
static func copy_file(source_file: String, dest_file: String) -> int:
	var data = FileAccess.get_file_as_bytes(source_file)
	if data.is_empty() and not FileAccess.file_exists(source_file):
		push_error("DirAccess Helper Error: Source file not found or empty data: %s" % source_file)
		return ERR_DOES_NOT_EXIST
		
	var file = FileAccess.open(dest_file, FileAccess.WRITE)
	if file == null:
		push_error("DirAccess Helper Error: Could not open destination file for writing: %s" % dest_file)
		return ERR_CANT_OPEN
		
	file.store_buffer(data)
	file.close()
	return OK
