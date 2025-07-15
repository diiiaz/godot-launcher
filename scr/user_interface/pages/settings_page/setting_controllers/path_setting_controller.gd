extends SettingController

@export var line_edit: LineEdit


func set_value(value: Variant) -> void:
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(value as String)):
		line_edit.text = SettingsManager.get_setting_fallback_value(_setting)
		return
	line_edit.text = ProjectSettings.globalize_path(value as String)
	line_edit.tooltip_text = ProjectSettings.globalize_path(value as String)


func get_value_changed_signal() -> Signal:
	return line_edit.text_changed


func setup(controller: SettingData.Controller) -> void:
	controller = (controller as SettingData.ControllerPath)


func _on_button_pressed() -> void:
	var file_dialog: FileDialog = DirectorySelector.create(_on_file_dialog_selected_directory)
	file_dialog.current_dir = ProjectSettings.globalize_path(line_edit.text) if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(line_edit.text)) else SettingsManager.get_setting_fallback_value(_setting)
	get_viewport().add_child(file_dialog)


func _on_file_dialog_selected_directory(dir_path: String) -> void:
	line_edit.text = dir_path
	line_edit.text_changed.emit(dir_path)
