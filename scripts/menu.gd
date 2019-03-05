extends Node2D

var state = "press"
var press_timer = -1
var max_press_timer = 60
var bg_move = 3
var max_bg_move = 15
var option = 1
var max_option = 1
var transition_alpha = 1
var change_alpha = 0.1

onready var audio = get_node("AudioStreamPlayer2D")
onready var bg = get_node("bg")
onready var transition = get_node("transition")
onready var press_label = get_node("press_label")
onready var hs_label = get_node("hs_label")
onready var buttons = get_node("buttons")

onready var snd_select = preload("res://sounds/select.wav")

func _ready():
	buttons.visible = false
	hs_label.visible = false
	transition.visible = true
	if global.menu_init:
		press_label.visible = false
		hs_label.visible = true
		buttons.visible = true
		state = "menu"

func _process(delta):
	transition.set_modulate(Color(1, 1, 1, transition_alpha))
	if state == "press":
		if transition_alpha > 0:
			transition_alpha -= change_alpha
		if (Input.is_action_just_pressed("player1_attack") or Input.is_action_just_pressed("player1_special")) and press_timer < 0:
			press_timer = max_press_timer
			bg_move = max_bg_move
			play_audio(snd_select)
		if press_timer > 0:
			press_timer -= 1
			var flash = press_timer / 3
			if flash % 2 == 0:
				press_label.visible = true
			else:
				press_label.visible = false
		elif press_timer == 0:
			press_label.visible = false
			hs_label.visible = true
			buttons.visible = true
			global.menu_init = true
			state = "menu"
	elif state == "menu":
		if transition_alpha > 0:
			transition_alpha -= change_alpha
		if bg_move > 3:
			bg_move -= 1
			
		if Input.is_action_just_pressed("player1_up"):
			option -= 1
		if Input.is_action_just_pressed("player1_down"):
			option += 1
		if option < 1:
			option = max_option
		elif option > max_option:
			option = 1
			
		for button in buttons.get_children():
			button.highlight(option)
		if Input.is_action_just_pressed("player1_attack") or Input.is_action_just_pressed("player1_special"):
			for button in buttons.get_children():
				button.select(option)
			press_timer = max_press_timer
			bg_move = max_bg_move
			transition_alpha = 0
			play_audio(snd_select)
			state = "select"
	else:
		if press_timer > 0:
			press_timer -= 1
			if press_timer < max_press_timer / 2 and transition_alpha < 1:
				transition_alpha += change_alpha
		else:
			global.menu_option = option
			get_tree().change_scene("res://scenes/charselect.tscn")
	if bg_move > 0:
		bg.set_position(Vector2(bg.get_position().x, bg.get_position().y + bg_move))
		if bg.get_position().y > 250:
			bg.set_position(Vector2(get_position().x, -250))

func play_audio(snd):
	audio.stream = snd
	audio.play(0)