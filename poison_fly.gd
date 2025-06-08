extends "res://fly.gd"

class_name PoisonFly

func _ready():
	animation_player.play()
	if Global.debug:
		info_label.visible = true
		info_label.text = "POISON: %d" % speed
	food_value = -15
	point_value = speed * 0.5
