extends CustomMenuButton
class_name SortingMenuButton

signal sorting_changed(sort_info: SortInfo)

const SORT_NEWEST_ICON_TEXTURE = preload("uid://beyeib7qfhua2")
const SORT_OLDEST_ICON_TEXTURE = preload("uid://dxa5x3uqk2vs1")

var _selected_sort_index: int = -1
var _selected_sort_option_index: int = -1

var _item_index_sort_item_map: Dictionary[int, SortItem]

var _sort_info: SortInfo


func _init() -> void:
	_sort_info = SortInfo.new()


func _ready() -> void:
	super._ready()
	get_popup().hide_on_item_selection = false
	get_popup().hide_on_checkable_item_selection = false
	get_popup().index_pressed.connect(_on_index_pressed)


func setup(sort_items: Array[SortItem], selected_sort_index: int, selected_sort_option_index: int) -> void:
	var index: int = 0
	for sort_item: SortItem in sort_items:
		add_item(sort_item.get_item())
		_item_index_sort_item_map[index] = sort_item
		index += 1
	add_item(Item.new().set_separator_state(true))
	
	_selected_sort_index = selected_sort_index
	_selected_sort_option_index = selected_sort_option_index
	
	_sort_info.select_item(_selected_sort_index, _item_index_sort_item_map.get(_selected_sort_index))
	_sort_info.set_invert_state(_selected_sort_option_index)
	update_text_and_icon()


func _on_about_to_popup() -> void:
	super._on_about_to_popup()
	# sort option setup
	var selected_index: int = _selected_sort_index
	get_popup().set_item_checked(selected_index, true)
	update_sort_options()


func _on_index_pressed(index: int) -> void:
	var has_pressed_sort_method_button: bool = _item_index_sort_item_map.size() > index
	if has_pressed_sort_method_button:
		get_popup().set_item_checked(_selected_sort_index, false)
		_selected_sort_index = index
		get_popup().set_item_checked(_selected_sort_index, true)
		_sort_info.select_item(_selected_sort_index, _item_index_sort_item_map.get(_selected_sort_index))
	else:
		var sort_item: SortItem = _item_index_sort_item_map.get(_selected_sort_index)
		if sort_item.has_inverted_options():
			_selected_sort_option_index = index - (_item_index_sort_item_map.size() + 1)
			_sort_info.set_invert_state(_selected_sort_option_index)
	update_sort_options()
	sorting_changed.emit(_sort_info)


func update_sort_options() -> void:
	var sort_item: SortItem = _item_index_sort_item_map.get(_selected_sort_index)
	if _item_index_sort_item_map.size() + 1 < get_popup().item_count:
		get_popup().remove_item(get_popup().item_count - 1)
		get_popup().remove_item(get_popup().item_count - 1)
	if sort_item.has_inverted_options():
		get_popup().add_icon_radio_check_item(SORT_NEWEST_ICON_TEXTURE, sort_item._non_inverted_name)
		get_popup().add_icon_radio_check_item(SORT_OLDEST_ICON_TEXTURE, sort_item._inverted_name)
		get_popup().set_item_checked(_selected_sort_option_index + (_item_index_sort_item_map.size() + 1), true)
	update_text_and_icon()


func update_text_and_icon() -> void:
	text = _sort_info.get_selected_item().get_item().get_label()
	icon = SORT_NEWEST_ICON_TEXTURE if not bool(_selected_sort_option_index) else SORT_OLDEST_ICON_TEXTURE 
	


func get_sort_info() -> SortInfo:
	return _sort_info


class SortItem extends RefCounted:
	var _item: CustomMenuButton.Item
	var _sort_method: Callable
	var _non_inverted_name: String
	var _inverted_name: String
	
	func _init(text: String, icon: Texture2D, method: Callable) -> void:
		_sort_method = method
		_item = CustomMenuButton.Item.new().set_label(text).set_checkable_type(Item.CHECKABLE_TYPE.RADIO_BUTTON).set_icon(icon)
	
	func add_inverted_options(non_inverted_name: String, inverted_name: String) -> SortItem:
		_non_inverted_name = non_inverted_name
		_inverted_name = inverted_name
		return self
	
	func has_inverted_options() -> bool:
		return not (_non_inverted_name.is_empty() and _inverted_name.is_empty())
	
	func get_item() -> CustomMenuButton.Item: return _item
	func get_sort_method() -> Callable: return _sort_method


class SortInfo extends RefCounted:
	var _selected_index: int = -1
	var _selected_item: SortItem = null
	var _inverted: bool = false
	
	func select_item(index: int, item: SortItem) -> void:
		_selected_index = index
		_selected_item = item
	
	func set_invert_state(inverted: bool) -> void:
		_inverted = inverted
	
	func get_selected_index() -> int: return _selected_index
	func get_selected_item() -> SortItem: return _selected_item
	func is_inverted() -> bool: return _inverted
