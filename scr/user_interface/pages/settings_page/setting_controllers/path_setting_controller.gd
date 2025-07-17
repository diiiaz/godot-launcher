extends SettingController

signal changed(path: String)

@export var path_label: Label


func set_value(value: Variant) -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(value as String)):
		path_label.text = SettingsManager.get_setting_fallback_value(_setting)
		return
	path_label.text = ProjectSettings.globalize_path(value as String)
	path_label.tooltip_text = ProjectSettings.globalize_path(value as String)


func get_value_changed_signal() -> Signal:
	return self.changed


func setup(controller: SettingData.Controller) -> void:
	controller = (controller as SettingData.ControllerPath)


func _on_file_dialog_selected_directory(dir_path: String) -> void:
	path_label.text = dir_path
	changed.emit(dir_path)
	#path_label.text_changed.emit(dir_path)


func _on_browse_directories_button_pressed() -> void:
	var file_dialog: FileDialog = DirectorySelector.create(_on_file_dialog_selected_directory)
	file_dialog.current_dir = get_current_dir()
	get_viewport().add_child(file_dialog)


func _on_open_directory_button_pressed() -> void:
	OS.shell_open(get_current_dir())


func get_current_dir() -> String:
	return ProjectSettings.globalize_path(path_label.text) if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path_label.text)) else SettingsManager.get_setting_fallback_value(_setting)
