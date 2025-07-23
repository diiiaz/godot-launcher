extends CustomMenuButton
class_name FilterMenuButton

const CLEAR_ICON_TEXTURE = preload("uid://c1xa4yf1i8t8j")

signal filter_changed(filter: FilterInfo)

var _filter_info: FilterInfo


func _init() -> void:
	_filter_info = FilterInfo.new()
	clear_items()
	get_popup().hide_on_item_selection = false
	get_popup().hide_on_checkable_item_selection = false
	get_popup().index_pressed.connect(_on_index_pressed)


func clear_items() -> void:
	get_popup().clear(true)
	_items.clear()
	_filter_info.clear()
	add_item(Item.new().set_label("CLEAR").set_icon(CLEAR_ICON_TEXTURE))
	add_item(Item.new().set_separator_state(true))


func _on_index_pressed(index: int) -> void:
	if index == 0:
		for item: Item in _items:
			if item.is_checked():
				item.set_check_state(false)
		_filter_info.clear()
		filter_changed.emit(_filter_info)
		update()
		return
	toggle_filter_index(index)


func set_filter(index: int, checked: bool) -> void:
	get_popup().set_item_checked(index, checked)
	var filter_name: String = get_popup().get_item_text(index)
	var is_checked: bool = get_popup().is_item_checked(index)
	
	_items[index].set_check_state(is_checked)
	if is_checked:
		_filter_info.add_filter(filter_name)
	else:
		_filter_info.remove_filter(filter_name)
	
	filter_changed.emit(_filter_info)


func toggle_filter_index(index: int) -> void:
	set_filter(index, not get_popup().is_item_checked(index))


func get_filter_info() -> FilterInfo:
	return _filter_info


class FilterInfo extends RefCounted:
	var _filter: Array[String]
	
	func clear() -> void:
		_filter.clear()
	
	func add_filter(filter: String) -> void:
		if _filter.has(filter):
			return
		_filter.append(filter)
	
	func remove_filter(filter: String) -> void:
		if _filter.has(filter):
			_filter.erase(filter)
	
	func add_filters(filters: Array[String]) -> void:
		for filter in filters:
			add_filter(filter)
	
	func get_filter() -> Array[String]:
		return _filter
