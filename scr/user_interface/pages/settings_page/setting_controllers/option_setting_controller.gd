extends SettingController

@export var option_button: OptionButton


func set_value(value: Variant) -> void:
	option_button.selected = value


func get_value_changed_signal() -> Signal:
	return option_button.item_selected


func setup(controller: SettingData.Controller) -> void:
	controller = (controller as SettingData.ControllerOption)
	for option: String in controller.get_options():
		option_button.add_item(option)
	#option_button.min_value = controller.get_min()
	#option_button.max_value = controller.get_max()
	#option_button.step = controller.get_step()
