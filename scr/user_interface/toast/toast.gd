extends Control
class_name Toast

const DEFAULT_DURATION: float = 2.0
const DEFAULT_HUE: float = 0.5

@onready var _icon: TextureRect = %Icon
@onready var _title_label: Label = %TitleLabel
@onready var _progress_bar: ProgressBar = %ProgressBar

var _sibling: Control
var _duration: float = 2.0
var _opened: bool = false
var _mouse_is_inside: bool = false
var _time: float = 0.0:
	set(v):
		_time = v
		_progress_bar.value = _time


func setup(title: String, color_hue: float = DEFAULT_HUE, duration: float = DEFAULT_DURATION, icon: Texture2D = null) -> void:
	if not is_node_ready():
		await self.ready
		await get_tree().process_frame
	_title_label.text = title
	_progress_bar.value = 0.0
	self.set_duration(duration).set_icon(icon).set_hue(color_hue)


func set_sibling(sibling: Control) -> Toast:
	_sibling = sibling
	return self

func set_icon(icon: Texture2D) -> Toast:
	_icon.visible = icon != null
	_icon.texture = icon
	return self

func set_duration(duration: float) -> Toast:
	_duration = duration
	_progress_bar.max_value = duration if duration != -1 else 1.0
	_progress_bar.step = _progress_bar.max_value / 100.0
	return self

func set_hue(hue: float) -> Toast:
	self_modulate = Color.from_ok_hsl(hue, 0.8, 0.2)
	_icon.self_modulate = Color.from_ok_hsl(hue, 0.8, 0.8)
	_progress_bar.self_modulate = Color.from_ok_hsl(hue, 0.8, 0.4)
	#_progress_bar.self_modulate = Color.from_ok_hsl(hue, 0.8, 0.6, 0.5)
	return self


func open() -> void:
	if not is_node_ready():
		await self.ready
	await get_tree().process_frame
	global_position = _sibling.global_position + Vector2(_sibling.custom_minimum_size.x, 0)
	show()
	_opened = true


func close() -> void:
	_opened = false
	var _tween: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC).set_parallel()
	_tween.tween_property(self, "global_position", _sibling.global_position + Vector2(_sibling.custom_minimum_size.x, 0), 0.3)
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.finished.connect(
		func():
			if _sibling != null and not _sibling.is_queued_for_deletion():
				_sibling.queue_free()
				_sibling = null
			queue_free()
	)

func _process(delta: float) -> void:
	if _sibling == null or not _opened:
		return
	if _duration != -1:
		if not _mouse_is_inside:
			self._time += delta
		if _time >= _duration:
			close()
	if abs(global_position.length() - _sibling.global_position.length()) < 1:
		return
	global_position = global_position.lerp(_sibling.global_position, delta * 10)


func set_progress(percentage: float) -> void:
	_progress_bar.value = percentage
	if _progress_bar.value >= 1.0:
		close()


func _on_mouse_entered() -> void:
	_mouse_is_inside = true
	self._time = 0.0

func _on_mouse_exited() -> void:
	_mouse_is_inside = false
