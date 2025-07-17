extends PanelContainer

signal pressed(tag_name: String)

@onready var tag_name_label: Label = %TagNameLabel

var _tag_name: String = ""

func setup(tag_name: String, hue: float = -1) -> void:
	_tag_name = tag_name
	tag_name_label.text = "#" + tag_name
	if hue < 0.0 or hue > 1.0:
		hue = TagsManager.get_tag_hue(tag_name)
	self_modulate = Color.from_ok_hsl(hue, 0.7, 0.4)
	tag_name_label.self_modulate = Color.from_ok_hsl(hue, 1.0, 0.9)


func _on_main_button_pressed() -> void:
	pressed.emit(_tag_name)
