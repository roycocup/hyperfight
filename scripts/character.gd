extends KinematicBody2D

export var player_num = 1

var score = 0
var score_balls
var anim = "idle"
var orig_pos = Vector2()
var linear_vel = Vector2()
var walk_speed = 50
var air_speed = 90
var h_dash_speed = 150
var v_dash_speed = 300
var jump = 300
var h_dash_jump = 100
var gravity = 13
var attack_gravity = 10
var special_move = 70
var special_jump = 150
var left_bound = -125
var right_bound = 125
var other_player
var last_input = "none"
var last_input_frames = 0
var on_floor = false
var attacking = false
var attacked = false
var can_dash = true
var can_attack = true
var dead = false
var can_act = true
var win = false
var h_airdashing = false
var v_airdashing = false
var alpha = 1
var curr_frame_delay = 0
var dash_frames = 10
var curr_dash_frames = 0

onready var game = get_parent()
onready var sprite = get_node("Sprite")
onready var anim_player = get_node("AnimationPlayer")
onready var audio = get_node("AudioStreamPlayer2D")
onready var effect_dash = preload("res://scenes/effect_dash.tscn")

func check_player_input(input):
	if not can_act:
		return false
	if player_num == 1:
		return Input.is_action_pressed("player1_" + input)
	else:
		return Input.is_action_pressed("player2_" + input)
		
func check_player_just_input(input):
	if not can_act:
		return false
	var inputted
	if player_num == 1:
		inputted = Input.is_action_just_pressed("player1_" + input)
	else:
		inputted = Input.is_action_just_pressed("player2_" + input)
	if inputted:
		last_input = input
		last_input_frames = 0
		return inputted
		
func stop_act():
	can_act = false
	can_attack = false

func start_act():
	can_act = true
	dead = false
	anim = "idle"
	anim_player.play(anim)
	global.frame_delay = 0

func start_attack():
	can_attack = true
	
func can_kill(other_num):
	return can_act and can_dash and anim != "special" and player_num != other_num

func kill(knockback):
	linear_vel = knockback
	set_position(Vector2(get_position().x, get_position().y - 32))
	stop_act()
	attacking = false
	dead = true
	anim = "fall"
	anim_player.play(anim)
	
func inc_score():
	score = score_balls.inc_score()
	
func win_score():
	score = score_balls.win_score()

func dec_score():
	score -= 1
	score_balls.use_ball()

func update_score():
	score_balls.remove_temps()

func win():
	win = true
	
func reset():
	set_position(orig_pos)
	attacking = false
	dead = false
	can_attack = false
	can_dash = true
	win = false
	score = score_balls.reset_score()

func attack():
	pass

func special():
	pass

func super():
	pass

func process_move():
	var jumped = false
	if on_floor:
		can_dash = true
		if not dead or linear_vel.y == 0:
			linear_vel.x = 0
		if check_player_input("left"):
			linear_vel.x -= walk_speed
		if check_player_input("right"):
			linear_vel.x += walk_speed
	if check_player_input("up") and on_floor:
		linear_vel.x = 0
		last_input = "up"
		last_input_frames = 0
		if check_player_input("left"):
			linear_vel.x -= air_speed
			last_input = "upleft"
		if check_player_input("right"):
			linear_vel.x += air_speed
			last_input = "upright"
		linear_vel.y = -jump
		on_floor = false
		jumped = true
	
	var previous_input = last_input
	var past_input_frames = last_input_frames
	if can_dash:
		alpha = 1
	if not jumped:
		if check_player_just_input("left") and (previous_input == "left" or previous_input == "upleft") and past_input_frames <= 12 and can_dash:
			last_input = "none"
			linear_vel.x = -h_dash_speed
			linear_vel.y = -h_dash_jump
			if not on_floor:
				h_airdashing = true
				curr_dash_frames = 0
			on_floor = false
			can_dash = false
			alpha = 0.5
			var e = effect_dash.instance()
			e.set_position(get_position())
			e.scale.x = -1
			get_parent().add_child(e)
		if check_player_just_input("right") and (previous_input == "right" or previous_input == "upright") and past_input_frames <= 12 and can_dash:
			last_input = "none"
			linear_vel.x = h_dash_speed
			linear_vel.y = -h_dash_jump
			if not on_floor:
				h_airdashing = true
				curr_dash_frames = 0
			on_floor = false
			can_dash = false
			alpha = 0.5
			var e = effect_dash.instance()
			e.set_position(get_position())
			e.scale.x = 1
			get_parent().add_child(e)
		if not on_floor:
			if check_player_just_input("up") and (previous_input == "up" or previous_input == "upleft" or previous_input == "upright") and past_input_frames <= 12 and can_dash:
				last_input = "none"
				linear_vel.x = 0
				linear_vel.y = 0
				v_airdashing = true
				curr_dash_frames = 0
				can_dash = false
				alpha = 0.5
				var e = effect_dash.instance()
				e.set_position(Vector2(get_position().x, get_position().y + 24))
				e.rotation_degrees = -90
				get_parent().add_child(e)
			if check_player_just_input("down") and previous_input == "down" and past_input_frames <= 12 and can_dash:
				last_input = "none"
				linear_vel.x = 0
				linear_vel.y = v_dash_speed
				v_airdashing = true
				curr_dash_frames = 0
				can_dash = false
				alpha = 0.5
				var e = effect_dash.instance()
				e.set_position(get_position())
				e.rotation_degrees = 90
				get_parent().add_child(e)
	if h_airdashing or v_airdashing:
		if curr_dash_frames >= dash_frames:
			h_airdashing = false
			v_airdashing = false
		else:
			curr_dash_frames += 1
	set_modulate(Color(1, 1, 1, alpha))

	if on_floor:
		if dead and linear_vel.y > 0:
			linear_vel.y *= -0.5
		else:
			linear_vel.y = 0
	elif not v_airdashing:
		if h_airdashing:
			linear_vel.y = 0
		else:
			linear_vel.y += gravity

func process_attack():
	pass

func process_anim():
	var new_anim = "idle"
	if win:
		new_anim = "win"
	elif dead:
		if on_floor:
			new_anim = "dead"
		else:
			new_anim = "fall"
	elif attacking:
		if anim == "super":
			new_anim = "super"
		elif anim == "special":
			new_anim = "special"
		else:
			new_anim = "attack"
	elif not on_floor:
		new_anim = "jump"
	elif linear_vel.x != 0:
		new_anim = "walk_forwards"
		if sign(sprite.scale.x) != sign(linear_vel.x):
			new_anim = "walk_backwards"
	if anim != new_anim:
		anim = new_anim
		anim_player.play(anim)

func process_frame():
	last_input_frames += 1
	sprite.get_material().set_shader_param("white_amount", 0)
	
	on_floor = test_move(get_transform(), Vector2(0, 1))
	
	if not attacking and can_dash and can_attack:
		if ((check_player_just_input("attack") and check_player_just_input("special")) or check_player_just_input("super")) and score >= 2:
			attacking = true
			super()
		elif check_player_just_input("attack"):
			attacking = true
			attack()
		elif check_player_just_input("special") and score > 0:
			attacking = true
			special()
	
	process_attack()
	if not attacking:
		process_move()
		if get_position().x < other_player.get_position().x:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1
	
	move_and_slide(linear_vel)
		
	if get_position().x < left_bound:
		set_position(Vector2(left_bound, get_position().y))
		if anim == "special":
			linear_vel.x *= -0.1
		else:
			linear_vel.x = 0
	if get_position().x > right_bound:
		set_position(Vector2(right_bound, get_position().y))
		if anim == "special":
			linear_vel.x *= -0.1
		else:
			linear_vel.x = 0
	
	process_anim()

func set_other_player(new_other_player):
	other_player = new_other_player

func play_audio(snd):
	audio.stream = snd
	audio.play(0)

func _ready():
	orig_pos = get_position()
	anim_player.play(anim)
	if player_num == 1:
		score_balls = get_node("../label_player1/score_balls")
	else:
		score_balls = get_node("../label_player2/score_balls")
		sprite.scale.x = -1

func _process(delta):
	if other_player != null:
		if curr_frame_delay <= 0:
			process_frame()
			anim_player.playback_speed = 1.0 / (global.frame_delay + 1)
			curr_frame_delay = global.frame_delay
		else:
			curr_frame_delay -= 1