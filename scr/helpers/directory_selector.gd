extends RefCounted
class_name DirectorySelector

static func create(callback: Callable) -> FileDialog:
	var file_dialog: FileDialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.use_native_dialog = true
	file_dialog.dir_selected.connect(callback)
	file_dialog.popup_centered.call_deferred()
	return file_dialog
