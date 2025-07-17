extends MenuButton
class_name CustomMenuButton

var _items: Array[CustomMenuButton.Item]


func _ready() -> void:
	#get_popup().index_pressed.connect(func(_unused): update.call_deferred())
	about_to_popup.connect(_on_about_to_popup)


func update() -> void:
	get_popup().clear(true)
	for item: CustomMenuButton.Item in _items:
		load_item_to_ui(item)


func add_item(item: Item) -> void:
	_items.append(item)
	load_item_to_ui(item)


func _on_about_to_popup() -> void:
	update()


func load_item_to_ui(item: CustomMenuButton.Item) -> void:
	var popup: PopupMenu = get_popup()
	if item.is_separator():
		popup.add_separator(item.get_label())
		return
	if item.is_checkable():
		match item.get_checkable_type():
			CustomMenuButton.Item.CHECKABLE_TYPE.CHECKBOX:
				popup.add_icon_check_item(item.get_icon(), item.get_label())
			CustomMenuButton.Item.CHECKABLE_TYPE.RADIO_BUTTON:
				popup.add_icon_radio_check_item(item.get_icon(), item.get_label())
		popup.set_item_checked(-1, item.is_checked())
		popup.set_item_icon_modulate(-1, item.get_color())
		return
	popup.add_icon_item(item.get_icon(), item.get_label())
	popup.set_item_icon_modulate(-1, item.get_color())


class Item extends RefCounted:
	enum CHECKABLE_TYPE {
		CHECKBOX,
		RADIO_BUTTON
	}
	
	var _label: String = ""
	var _icon: Texture2D
	var _checkable: bool = false
	var _checkable_type: CHECKABLE_TYPE = CHECKABLE_TYPE.CHECKBOX
	var _checked: bool = false
	var _disabled: bool = false
	var _separator: bool = false
	var _color: Color = Color.WHITE
	
	func set_label(label: String) -> CustomMenuButton.Item:
		_label = label
		return self
	
	func set_icon(icon: Texture2D) -> CustomMenuButton.Item:
		_icon = icon
		return self
	
	func set_checkable_type(type: CHECKABLE_TYPE) -> CustomMenuButton.Item:
		_checkable = true
		_checkable_type = type
		return self
	
	func set_check_state(state: bool) -> CustomMenuButton.Item:
		_checked = state
		return self
	
	func set_disable_state(state: bool) -> CustomMenuButton.Item:
		_disabled = state
		return self
	
	func set_separator_state(state: bool) -> CustomMenuButton.Item:
		_separator = state
		return self
	
	func set_color(color: Color) -> CustomMenuButton.Item:
		_color = color
		return self
	
	func get_label() -> String: return _label
	func get_icon() -> Texture2D: return _icon
	func get_checkable_type() -> CHECKABLE_TYPE: return _checkable_type
	func get_color() -> Color: return _color
	func is_checkable() -> bool: return _checkable
	func is_checked() -> bool: return _checked
	func is_disabled() -> bool: return _disabled
	func is_separator() -> bool: return _separator
	
			
