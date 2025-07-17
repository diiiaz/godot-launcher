extends RefCounted
class_name SettingData

var _controller: Controller
var _translation_key: String
var _tooltip: String


func _init(translation_key: String, tooltip: String, controller: Controller) -> void:
	_translation_key = translation_key
	_controller = controller
	_tooltip = tooltip


func get_controller() -> Controller:
	return _controller

func get_translation_key() -> String:
	return _translation_key

func get_tooltip() -> String:
	return _tooltip



@abstract class Controller extends RefCounted:
	enum CONTROLLER_TYPE {
		BOOLEAN,
		NUMBER,
		OPTION,
		PATH,
	}
	
	@abstract func get_controller_type() -> CONTROLLER_TYPE


class ControllerBoolean extends Controller:
	func get_controller_type() -> CONTROLLER_TYPE: return CONTROLLER_TYPE.BOOLEAN


class ControllerNumber extends Controller:
	var _min: float = 0.0
	var _max: float = 1.0
	var _step: float = 0.01
	
	func get_controller_type() -> CONTROLLER_TYPE: return CONTROLLER_TYPE.NUMBER
	
	@warning_ignore("shadowed_global_identifier")
	func set_range(min: float, max: float, step: float) -> ControllerNumber:
		set_min(min)
		set_max(max)
		set_step(step)
		return self
	
	@warning_ignore("shadowed_global_identifier")
	func set_min(min: float) -> ControllerNumber:
		_min = min
		return self
	
	@warning_ignore("shadowed_global_identifier")
	func set_max(max: float) -> ControllerNumber:
		_max = max
		return self
	
	func set_step(step: float) -> ControllerNumber:
		_step = step
		return self
	
	func get_min() -> float: return _min
	func get_max() -> float: return _max
	func get_step() -> float: return _step


class ControllerOption extends Controller:
	var _options: PackedStringArray
	
	func get_controller_type() -> CONTROLLER_TYPE: return CONTROLLER_TYPE.OPTION
	
	func add_option(option: String) -> ControllerOption:
		_options.append(option)
		return self

	func add_options(options: PackedStringArray) -> ControllerOption:
		_options.append_array(options)
		return self
	
	func get_options() -> PackedStringArray: return _options


class ControllerPath extends Controller:
	func get_controller_type() -> CONTROLLER_TYPE: return CONTROLLER_TYPE.PATH
