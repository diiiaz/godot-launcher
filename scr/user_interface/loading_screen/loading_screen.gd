extends CanvasLayer

@onready var loading_screen_background: Panel = %LoadingScreenBackground
@onready var control: Control = %Control
@onready var logo_texture_rect: TextureRect = %LogoTextureRect

var _start_pos: Vector2

func _init() -> void:
	visible = true

func _ready() -> void:
	_start_pos = logo_texture_rect.position
	show()
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	await get_tree().create_timer(0.1).timeout
	var tweener: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC).set_parallel()
	tweener.tween_property(logo_texture_rect, "position", _start_pos, 0.4).from(logo_texture_rect.position + Vector2(-1, 1) * 100)
	tweener.tween_property(logo_texture_rect, "modulate:a", 1.0, 0.4).from(0.0)


func close() -> void:
	await get_tree().create_timer(0.7).timeout
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tweener: Tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO).set_parallel()
	tweener.tween_property(loading_screen_background, "modulate:a", 0.0, 0.3).from(1.0)
	tweener.tween_property(logo_texture_rect, "position", logo_texture_rect.position + Vector2(1, -1) * 1000, 0.6).from(_start_pos)
	tweener.tween_property(logo_texture_rect, "modulate:a", 0.0, 0.4).from(1.0)
	tweener.finished.connect(func(): queue_free())
