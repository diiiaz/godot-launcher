extends Control
class_name PageController

signal changed_page(page_index: int)

const MAX_AMOUNT_OF_BUTTONS: int = 7

@onready var _page_buttons: Array[PageButton] = [%PageButton0, %PageButton1, %PageButton2, %PageButton3, %PageButton4, %PageButton5, %PageButton6]
@onready var highlight_panel: PanelContainer = %HighlightPanel
@onready var left_arrow_button: Button = %LeftArrowButton
@onready var right_arrow_button: Button = %RightArrowButton

var _amount_of_pages: int = 1
var _current_page: int = 0
var _current_page_button: PageButton = null


func setup(amount_of_pages: int) -> void:
	_current_page = 0
	_current_page_button = _page_buttons[_current_page]
	set_amount_of_pages(amount_of_pages)


func update() -> void:
	travel_to_page(_current_page, true, true, false)


func travel_to_page(page: int, stop_signal: bool = false, force_update: bool = false, animate: bool = true) -> void:
	if clampi(page, 0, (_amount_of_pages - 1)) == _current_page and not force_update:
		return
	
	_current_page = clampi(page, 0, (_amount_of_pages - 1))
	
	if not stop_signal:
		changed_page.emit(_current_page)
	
	var has_less_than_max: bool = (_amount_of_pages - 1) <= MAX_AMOUNT_OF_BUTTONS
	var has_start_ellipsis: bool = _current_page >= 4 and not has_less_than_max
	var has_end_ellipsis: bool = (_amount_of_pages - 1) - _current_page >= 4 and not has_less_than_max
	
	var current_page_button_index: int = floor(_page_buttons.size() / 2.0) if ((_current_page >= 3 and (_amount_of_pages - 1) - _current_page >= 3) and not has_less_than_max) else -1
	var wanted_buttons: Array[PageButton] = _page_buttons.filter(func(_page_button: PageButton): return _page_button.get_page_number() == _current_page)
	if current_page_button_index == -1:
		if not wanted_buttons.is_empty():
			current_page_button_index = wanted_buttons[0].get_index()
		else:
			current_page_button_index = 0
	_current_page_button = _page_buttons[current_page_button_index]
	
	for page_button: PageButton in _page_buttons:
		var page_number: int = _current_page - (_current_page_button.get_index() - page_button.get_index())
		page_button.set_page_number(page_number)
		page_button.visible = page_button.get_index() <= (_amount_of_pages - 1) if has_less_than_max else true
	
	if has_start_ellipsis:
		get_start_ellipsis_button().set_page_number(-1)
		get_page_button(0).set_page_number(0)
	if has_end_ellipsis:
		get_end_ellipsis_button().set_page_number(-1)
		get_page_button(-1).set_page_number((_amount_of_pages - 1))
	
	for page_button: PageButton in _page_buttons:
		page_button.animate_text()
	
	await get_tree().process_frame
	
	var tweener: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_parallel()
	tweener.tween_property(highlight_panel, "global_position", _current_page_button.global_position, 0.2 if animate else 0.01).from_current()
	tweener.tween_property(left_arrow_button, "modulate:a", 0.0 if _current_page == 0 else 1.0, 0.1 if animate else 0.01).from_current()
	tweener.tween_property(right_arrow_button, "modulate:a", 0.0 if _current_page == (_amount_of_pages - 1) else 1.0, 0.1 if animate else 0.01).from_current()
	left_arrow_button.disabled = _current_page == 0
	left_arrow_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if _current_page == 0 else Control.CURSOR_POINTING_HAND
	right_arrow_button.disabled = _current_page == (_amount_of_pages - 1)
	right_arrow_button.mouse_default_cursor_shape = Control.CURSOR_ARROW if _current_page == (_amount_of_pages - 1) else Control.CURSOR_POINTING_HAND

func _on_page_button_pressed(page_button: PageButton) -> void:
	travel_to_page(page_button.get_page_number())


func get_page_button(index: int) -> PageButton:
	return _page_buttons[index]

func set_amount_of_pages(pages_amount: int) -> void:
	if pages_amount <= 1:
		hide()
		return
	
	show()
	for page_button: PageButton in _page_buttons:
		if not page_button.pressed.is_connected(_on_page_button_pressed):
			page_button.pressed.connect(_on_page_button_pressed.bind(page_button))
		var page_number: int = _current_page - (get_page_button(0).get_index() - page_button.get_index())
		page_button.set_page_number(page_number)
	_current_page = 0
	_current_page_button = _page_buttons[0]
	_amount_of_pages = pages_amount
	update()

func get_start_ellipsis_button() -> PageButton:
	return get_page_button(1)

func get_end_ellipsis_button() -> PageButton:
	return get_page_button(-2)

func get_current_page() -> int:
	return _current_page


func _on_left_arrow_button_pressed() -> void:
	travel_to_page(_current_page - 1)

func _on_right_arrow_button_pressed() -> void:
	travel_to_page(_current_page + 1)
