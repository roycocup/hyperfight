extends Node2D

var transition_alpha = 1
var change_alpha = 0.1
var win_player_num = 1
var state = "fight"
var win_timer = 120
var max_win_timer = 120
var delay_timer = -1
var max_delay_timer = 60
var player_xoffset = 70
var player_yoffset = 25
var player1
var player2

onready var label_center = get_node("label_center")
onready var transition = get_node("transition")
onready var audio = get_node("AudioStreamPlayer2D")

onready var char_goto = preload("res://scenes/char_goto.tscn")
onready var char_darkgoto = preload("res://scenes/char_darkgoto.tscn")

onready var snd_ready = preload("res://sounds/ready.ogg")
onready var snd_fight = preload("res://sounds/fight.ogg")
onready var snd_fight2 = preload("res://sounds/fight2.ogg")
onready var snd_fight3 = preload("res://sounds/fight3.ogg")
onready var snd_player1win = preload("res://sounds/player1win.ogg")
onready var snd_player2win = preload("res://sounds/player2win.ogg")
onready var snd_ko = preload("res://sounds/ko.ogg")
onready var snd_superko = preload("res://sounds/superko.ogg")
onready var snd_perfect = preload("res://sounds/perfect.ogg")

func _ready():
	label_center.text = "Ready..."
	player1 = get_char_instance(global.player1_char)
	player1.player_num = 1
	player1.set_position(Vector2(-player_xoffset, player_yoffset))
	player2 = get_char_instance(global.player2_char)
	player2.player_num = 2
	player2.set_position(Vector2(player_xoffset, player_yoffset))
	add_child(player1)
	add_child(player2)
	player1.reset()
	player2.reset()
	player1.set_other_player(player2)
	player2.set_other_player(player1)
	transition.visible = true
	play_audio(snd_ready)

func get_char_instance(char_name):
	match char_name:
		"darkgoto":
			return char_darkgoto.instance()
	return char_goto.instance()

func inc_score(player_num):
	win_player_num = player_num
	max_win_timer = 90
	win_timer = max_win_timer
	global.frame_delay = 2
	delay_timer = max_delay_timer
	state = "ko"
	
func win(player_num):
	win_player_num = player_num
	max_win_timer = 90
	win_timer = max_win_timer
	global.frame_delay = 2
	delay_timer = max_delay_timer
	state = "super"

func _process(delta):
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	if state == "menu_title":
		if transition_alpha < 1 and win_timer < max_win_timer / 2:
			transition_alpha += change_alpha
	else:
		if transition_alpha > 0:
			transition_alpha -= change_alpha
	if win_timer > 0:
		win_timer -= 1
	if delay_timer > 0:
		delay_timer -= 1
	if win_timer == 0:
		win_timer_act()
	if delay_timer == 0:
		delay_timer_act()

func win_timer_act():
	win_timer = max_win_timer
	if state == "ko":
		label_center.visible = true
		if win_player_num == 1:
			player1.inc_score()
			player2.update_score()
		else:
			player2.inc_score()
			player1.update_score()
		play_audio(snd_ko)
		label_center.text = "K.O.!"
		state = "ready"
		if player1.score >= 5 or player2.score >= 5:
			state = "win"
	elif state == "super":
		label_center.visible = true
		if win_player_num == 1:
			player1.win_score()
			player2.update_score()
		else:
			player2.win_score()
			player1.update_score()
		play_audio(snd_superko)
		label_center.text = "SUPER K.O.!!"
		state = "win"
	elif state == "win":
		state = "menu_title"
		if player1.score >= 5:
			label_center.text = "Player 1 wins!"
			player1.win()
			if player2.score <= 0:
				state = "perfect"
			play_audio(snd_player1win)
		else:
			label_center.text = "Player 2 wins!"
			player2.win()
			if player1.score <= 0:
				state = "perfect"
			play_audio(snd_player2win)
		max_win_timer = 120
		win_timer = max_win_timer
	elif state == "ready":
		player1.start_act()
		player2.start_act()
		label_center.text = "Ready..."
		state = "fight"
		max_win_timer = 120
		win_timer = max_win_timer
	elif state == "fight":
		player1.start_attack()
		player2.start_attack()
		label_center.text = "FIGHT!"
		var rand = randi() % 3
		if rand == 0:
			play_audio(snd_fight)
		elif rand == 1:
			play_audio(snd_fight2)
		else:
			play_audio(snd_fight3)
		state = "go"
		max_win_timer = 60
		win_timer = max_win_timer
	elif state == "perfect":
		label_center.text = "PERFECT"
		play_audio(snd_perfect)
		state = "menu_title"
	elif state == "menu_title":
		get_tree().change_scene("res://scenes/menu.tscn")
	else:
		label_center.visible = false
		win_timer = -1

func play_audio(snd):
	audio.stream = snd
	audio.play(0)

func delay_timer_act():
	global.frame_delay -= 1
	if global.frame_delay <= 0:
		global.frame_delay = 0
		delay_timer = -1
	else:
		delay_timer = max_delay_timer
