extends "res://fly.gd"

func _ready():
	animation_player.play()
	if Global.debug:
		info_label.visible = true
		info_label.text = "POISON: %d" % speed
	food_value = -20
	point_value = 0
