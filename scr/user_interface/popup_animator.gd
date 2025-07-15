extends Node

@export var move_amount: int = 8

func _enter_tree() -> void:
	get_tree().node_added.connect(on_node_added)

func on_node_added(node: Node) -> void:
	if node is OptionButton or node is MenuButton:
		node.pressed.connect(_on_popup_opened.bind(node))
		node.get_popup().about_to_popup.connect(_on_popup_about_to_open.bind(node))


func _on_popup_opened(node: Control) -> void:
	node.get_popup().position.y -= move_amount
	create_tween().tween_property(node.get_popup(), "position:y", node.get_popup().position.y + move_amount * 2, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)


func _on_popup_about_to_open(node: Control) -> void:
	var main_popup_control: Control = node.get_popup().get_children(true)[0]
	main_popup_control.modulate.a = 0
	create_tween().tween_property(main_popup_control, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
