extends Node2D

onready var logo = get_node("label_logo")

func _on_transition_timer_timeout():
	if logo.visible:
		logo.visible = false
	else:
		get_tree().change_scene("res://scenes/menu.tscn")
