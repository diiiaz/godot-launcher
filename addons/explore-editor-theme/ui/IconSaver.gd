@tool
extends VBoxContainer

signal filesystem_changed()

# Public properties
var icon_name: String = "":
	set = set_icon_name
var type_name: String = "":
	set = set_type_name

# Utils
const _PluginUtils := preload("res://addons/explore-editor-theme/utils/PluginUtils.gd")

# Node references
@onready var save_button: Button = $SaveButton
@onready var save_dialog: FileDialog = $SaveDialog
@onready var status_message: Label = $Message

func _ready() -> void:
	visibility_changed.connect(self._clear_status)
	save_button.pressed.connect(self._on_save_button_pressed)
	save_dialog.file_selected.connect(self._on_file_selected)

# Properties
func set_icon_name(value : String) -> void:
	icon_name = value
	_clear_status()

func set_type_name(value : String) -> void:
	type_name = value
	_clear_status()

# Helpers
func _show_status(success : bool, message : String = "") -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	if (success):
		save_button.icon = get_theme_icon("StatusSuccess", "EditorIcons")
	else:
		save_button.icon = get_theme_icon("StatusError", "EditorIcons")

	if (message):
		status_message.text = message
		if (success):
			status_message.add_theme_color_override("font_color", get_theme_color("font_color", "Label"))
		else:
			status_message.add_theme_color_override("font_color", get_theme_color("error_color", "Editor"))

		status_message.show()
	else:
		status_message.hide()

func _clear_status() -> void:
	if (!_PluginUtils.get_plugin_instance(self)):
		return

	save_button.icon = null
	status_message.hide()

# Handlers
func _on_save_button_pressed() -> void:
	if (icon_name):
		if get_theme_icon(icon_name, type_name) is SVGTexture:
			save_dialog.current_file = "%s.svg" % icon_name
		else:
			save_dialog.current_file = "%s.png" % icon_name
	save_dialog.popup_centered()


func _on_file_selected(path: String) -> void:
	if (!has_theme_icon(icon_name, type_name)):
		_show_status(false, "Can't load icon. Is a valid icon selected?")
		return

	var unique_icon: Texture2D = get_theme_icon(icon_name, type_name).duplicate(true)
	var is_svg: bool = unique_icon is SVGTexture
	var image: Image = unique_icon.get_image()
	var error: Error
	if is_svg:
		var file = FileAccess.open(path, FileAccess.WRITE)
		error = file.get_open_error()
		file.store_string(unique_icon.get_source())
		file.close()
	else:
		error = unique_icon.get_image().save_png(path)
	
	if (error != OK):
		_show_status(false, "Error while saving icon: %s" % error_string(error))
		return

	_show_status(true)
	filesystem_changed.emit()
