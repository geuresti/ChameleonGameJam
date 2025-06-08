extends "res://fly.gd"

func _ready():
	animation_player.play()
	if Global.debug:
		info_label.visible = true
		info_label.text = "FAST: %d" % speed
	food_value = 10
	speed *= 1.5
	point_value = speed * 1.2
