extends Sprite

var player
var player_num = 1
var speed = 3
var left_bound = -250
var right_bound = 250
var curr_frame_delay = 0

onready var game = get_parent()
onready var anim_player = get_node("AnimationPlayer")
onready var effect = preload("res://scenes/effect_proj_goto_super_hit.tscn")

func _process(delta):
	if curr_frame_delay <= 0:
		set_position(Vector2(get_position().x + speed * scale.x, get_position().y))
		if get_position().x < left_bound:
			queue_free()
		if get_position().x > right_bound:
			queue_free()
			
		anim_player.playback_speed = 1.0 / (global.frame_delay + 1)
		curr_frame_delay = global.frame_delay
	else:
		curr_frame_delay -= 1

func _on_Area2D_body_entered(body):
	if body.is_in_group("char") and body.can_kill(player_num):
		player.stop_act()
		body.kill(Vector2(100 * scale.x, -350))
		game.win(player_num)
		var e = effect.instance()
		e.set_position(get_position())
		get_parent().add_child(e)
		queue_free()

func _on_Area2D_area_entered(area):
	if area.is_in_group("proj"):
		var e = effect.instance()
		e.set_position(get_position())
		get_parent().add_child(e)
		if area.is_in_group("super"):
			queue_free()