extends Page

@onready var settings_container: VBoxContainer = %SettingsContainer


func _ready() -> void:
	SettingsManager.updated.connect(func(_unused): settings_container.update())
	settings_container.update()

func get_icon() -> Texture2D:
	return preload("uid://bkv1bifk50l4r")


# ---------------------------------- Search Bar


func _on_search_bar_text_changed(new_text: String) -> void:
	settings_container.set_search_text(new_text)
	settings_container.update()
