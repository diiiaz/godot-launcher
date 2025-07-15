@tool
extends Node
class_name LoadEditorIconInParent

#var _parent: Node

@export var icon_name: String:
	set(v):
		icon_name = v
		update()
@export_placeholder("EditorIcons") var icon_theme_type: String = "":
	set(v):
		icon_theme_type = v
		update()


@export var texture_preview: Texture2D
@export_tool_button("Load in Parent", "AssetLib") var button: Callable = _pressed_button

func update() -> void:
	if EditorInterface.get_editor_theme().has_icon(icon_name, icon_theme_type if icon_theme_type != "" else "EditorIcons"):
		texture_preview = EditorInterface.get_editor_theme().get_icon(icon_name, icon_theme_type if icon_theme_type != "" else "EditorIcons")
	elif texture_preview != null:
		texture_preview = null

func _pressed_button() -> void:
	var parent = get_parent()
	
	if parent.get("texture") != null:
		parent.set("texture", texture_preview.duplicate(true))
		return
	elif parent.get("icon") != null:
		parent.set("icon", texture_preview.duplicate(true))
		return
	push_error("Parent does not have a 'texture' or 'icon' variable.")


#func _ready() -> void:
	#_parent = get_parent()
	#if _parent is not Control:
		#return
	#
	#if _parent.get("texture") != null:
		#pass
	#elif _parent.get("icon") != null:
		#pass


func _validate_property(property: Dictionary) -> void:
	if property.name == "texture_preview":
		property.usage |= PROPERTY_USAGE_READ_ONLY
