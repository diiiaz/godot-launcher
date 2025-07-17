extends PanelContainer
class_name SettingUI

const BOOLEAN_CONTROLLER = preload("uid://bbvwquqdvdb5o")
const NUMBER_CONTROLLER = preload("uid://cbka0pcjdtyr7")
const OPTION_CONTROLLER = preload("uid://qj14muq6hfe8")
const PATH_CONTROLLER = preload("uid://binhesqtrk4nk")

@onready var setting_name_label: Label = %SettingNameLabel
@onready var value_controller_container: PanelContainer = %ValueControllerContainer
@onready var hover_button: Button = %HoverButton


func setup(setting: Settings.SETTING) -> void:
	var setting_data: SettingData = SettingsManager.get_setting_data(setting)
	setting_name_label.text = setting_data.get_translation_key()
	hover_button.tooltip_text = setting_data.get_tooltip()
	
	var controller: SettingController
	
	if setting_data.get_controller() is SettingData.ControllerBoolean:	controller = BOOLEAN_CONTROLLER.instantiate()
	elif setting_data.get_controller() is SettingData.ControllerNumber:	controller = NUMBER_CONTROLLER.instantiate()
	elif setting_data.get_controller() is SettingData.ControllerOption:	controller = OPTION_CONTROLLER.instantiate()
	elif setting_data.get_controller() is SettingData.ControllerPath:	controller = PATH_CONTROLLER.instantiate()
	
	if controller == null:
		return
	
	controller.set_setting(setting)
	controller.setup(setting_data.get_controller())
	controller.set_value(SettingsManager.get_setting(setting))
	value_controller_container.add_child(controller)
	set_text_alpha(0.6)

func set_text_alpha(value: float) -> void:
	setting_name_label.self_modulate.a = value

#func build_number_controller() -> void:
	#var spinbox: SpinBox = SpinBox.new()
	#value_controller_container.add_child(spinbox)
#
#func build_option_controller() -> void:
	#var option_button: OptionButton = OptionButton.new()
	#value_controller_container.add_child(option_button)
#
#func build_path_controller() -> void:
	#var line_edit: LineEdit = LineEdit.new()
	#value_controller_container.add_child(line_edit)
