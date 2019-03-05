extends "res://scripts/character.gd"

onready var hitbox_special = get_node("hitbox_special")
onready var proj_attack = preload("res://scenes/proj_darkgoto_attack.tscn")
onready var proj_super = preload("res://scenes/proj_darkgoto_super.tscn")
onready var effect_hit = preload("res://scenes/effect_proj_darkgoto_attack_hit.tscn")

onready var snd_attack = preload("res://sounds/char_darkgoto_attack.ogg")
onready var snd_special = preload("res://sounds/char_darkgoto_special.ogg")
onready var snd_super = preload("res://sounds/char_darkgoto_super.ogg")
onready var snd_hit = preload("res://sounds/char_darkgoto_hit.ogg")

func attack():
	attacked = false
	linear_vel.x *= 0.25
	linear_vel.y = 0
	sprite.frame = 0
	play_audio(snd_attack)

func special():
	anim = "special"
	anim_player.play(anim)
	linear_vel.x = special_move * sprite.scale.x
	linear_vel.y = -special_jump
	sprite.frame = 0
	hitbox_special.monitoring = true
	dec_score()
	play_audio(snd_special)

func super():
	attacked = false
	anim = "super"
	anim_player.play(anim)
	linear_vel.x *= 0.25
	linear_vel.y = 0
	sprite.frame = 0
	for i in range(2):
		dec_score()
	play_audio(snd_super)
	
func kill(knockback):
	.kill(knockback)
	play_audio(snd_hit)

func process_attack():
	if attacking:
		if anim == "special":
			sprite.get_material().set_shader_param("white_amount", 0.5)
			if on_floor:
				if sprite.frame >= 1:
					linear_vel.x = 0
					linear_vel.y = 0
					attacking = false
			elif sprite.frame >= 2:
				linear_vel.y += attack_gravity
		else:
			if on_floor:
				linear_vel.x = 0
				linear_vel.y = 0
			else:
				linear_vel.y = attack_gravity
			if not attacked and sprite.frame >= 2:
				var p
				if anim == "super":
					p = proj_super.instance()
				else:
					p = proj_attack.instance()
				p.set_position(Vector2(get_position().x + 24 * sprite.scale.x, get_position().y))
				p.scale.x = sprite.scale.x
				p.player = self
				p.player_num = player_num
				p.set_up(on_floor)
				get_parent().add_child(p)
				attacked = true
	else:
		hitbox_special.monitoring = false
		hitbox_special.scale.x = sprite.scale.x

func _ready():
	walk_speed = 40
	air_speed = 100
	h_dash_speed = 120
	jump = 350
	special_move = 140
	special_jump = 250
	if player_num != 1:
		hitbox_special.scale.x = sprite.scale.x

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim != "special":
		attacking = false
		anim = "idle"
		anim_player.play(anim)

func _on_hitbox_special_body_entered(body):
	if body.is_in_group("char") and body.can_kill(player_num):
		stop_act()
		body.kill(Vector2(50 * sprite.scale.x, -250))
		game.inc_score(player_num)
		var e = effect_hit.instance()
		e.set_position(body.get_position())
		get_parent().add_child(e)