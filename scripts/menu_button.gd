extends Sprite

export var text = ""
export var option_num = 1

var select_timer = -1
var max_select_timer = 60

onready var label = get_node("label_text")

func _ready():
	label.text = text

func _process(delta):
	if select_timer > 0:
		select_timer -= 1
		var temp = select_timer / 3
		if temp % 2 == 0:
			label.visible = true
		else:
			label.visible = false
	else:
		label.visible = true

func highlight(highlight_num):
	if option_num == highlight_num:
		frame = 1
		label.add_color_override("font_color", Color(0.5, 1, 0.5))
	else:
		frame = 0
		label.add_color_override("font_color", Color(1, 1, 1))

func select(highlight_num):
	if option_num == highlight_num:
		select_timer = max_select_timer