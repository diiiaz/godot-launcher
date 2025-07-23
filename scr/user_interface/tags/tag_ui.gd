extends PanelContainer
class_name TagUI

signal pressed(tag: Tag)

@onready var tag_name_label: Label = %TagNameLabel
@onready var hash_icon_texture_rect: TextureRect = %HashIconTextureRect

var _tag: Tag


func setup(tag: Tag, hue: float = -1) -> void:
	_tag = tag
	tag_name_label.text = tag.get_name()
	if hue == -1: hue = tag.get_hue()
	self_modulate = Color.from_ok_hsl(hue, 0.7, 0.4)
	tag_name_label.self_modulate = Color.from_ok_hsl(hue, 1.0, 0.9)
	hash_icon_texture_rect.self_modulate = Color.from_ok_hsl(hue, 1.0, 0.9)


func _on_main_button_pressed() -> void:
	pressed.emit(_tag)
