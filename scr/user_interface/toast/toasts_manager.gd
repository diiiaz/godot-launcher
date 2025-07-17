extends Node
# ToastManager

const INFO_ICON_TEXTURE = preload("uid://3cxxjt1mj38b")
const WARNING_ICON_TEXTURE = preload("uid://ccf6nx3dgn3h")
const ERROR_ICON_TEXTURE = preload("uid://bw8oxtvrnpwq3")
const DOWNLOAD_ICON_TEXTURE = preload("uid://b7t2klcgpvtjc")

const DEFAULT_ERROR_DURATION: float = 5.0
const TOAST = preload("res://scr/user_interface/toast/toast.tscn")

@onready var static_container: VBoxContainer = %StaticToastsContainer


func create_info_toast(title: String, duration: float = Toast.DEFAULT_DURATION) -> Toast:
	return await _create_toast(title, 0.7, duration, INFO_ICON_TEXTURE)

func create_warning_toast(title: String, duration: float = Toast.DEFAULT_DURATION) -> Toast:
	return await _create_toast(title, 0.21, duration, WARNING_ICON_TEXTURE)

func create_error_toast(title: String, duration: float = DEFAULT_ERROR_DURATION) -> Toast:
	push_error(title)
	return await _create_toast(title, 0.05, duration, ERROR_ICON_TEXTURE)

func create_progress_toast(title: String) -> Toast:
	return await _create_toast(title, 0.5, -1, DOWNLOAD_ICON_TEXTURE)


func _create_toast(title: String, color_hue: float = Toast.DEFAULT_HUE, duration: float = Toast.DEFAULT_DURATION, icon: Texture2D = null) -> Toast:
	var toast: Toast = TOAST.instantiate()
	toast.hide()
	add_child.call_deferred(toast)
	await toast.ready
	toast.setup(title, color_hue, duration, icon)
	toast.size = Vector2(1, 1)
	#toast.set_deferred("size", Vector2.ZERO)
	
	var toast_static_sibling: Control = Control.new()
	static_container.add_child(toast_static_sibling)
	toast_static_sibling.custom_minimum_size = toast.size
	toast_static_sibling.size_flags_horizontal = Control.SIZE_SHRINK_END
	
	toast.global_position = toast_static_sibling.global_position
	toast.set_sibling(toast_static_sibling)
	
	toast.open()
	return toast
