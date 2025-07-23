@tool
extends Component
class_name UnfocusWhenClickedOutsideComponent

var _mouse_is_inside: bool


func parent_is_correct(parent: Node) -> bool:
	return parent is Control

func uncorrect_parent_error_message(__parent: Node) -> String:
	return "Parent of %s should be of or inherit the Control class" % [get_component_name()]

func get_component_name() -> String:
	return "UnfocusWhenClickedOutsideComponent"


func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return
	get_real_parent().gui_input.connect(_input)
	get_real_parent().mouse_entered.connect(func(): _mouse_is_inside = true)
	get_real_parent().mouse_exited.connect(func(): _mouse_is_inside = false)


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if not get_real_parent().has_focus() or event.is_echo():
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _mouse_is_inside:
		get_real_parent().release_focus()


func get_real_parent() -> Control:
	if _parent is SpinBox:
		return _parent.get_line_edit()
	return _parent
