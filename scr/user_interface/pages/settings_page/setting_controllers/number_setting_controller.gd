extends SettingController

@export var spinbox: SpinBox


func set_value(value: Variant) -> void:
	spinbox.value = value


func get_value_changed_signal() -> Signal:
	return spinbox.value_changed


func setup(controller: SettingData.Controller) -> void:
	controller = (controller as SettingData.ControllerNumber)
	spinbox.min_value = 1.0 if is_inf(controller.get_min()) else controller.get_min()
	spinbox.allow_lesser = is_inf(controller.get_min())
	spinbox.max_value = 1.0 if is_inf(controller.get_max()) else controller.get_max()
	spinbox.allow_greater = is_inf(controller.get_max())
	spinbox.step = controller.get_step()
