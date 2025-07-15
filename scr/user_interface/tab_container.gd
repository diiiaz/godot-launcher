extends TabContainer

func _ready() -> void:
	for page: Page in find_children("*", "Page", true, false):
		set_tab_icon(page.get_index(), page.get_icon())
