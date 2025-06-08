extends "res://fly.gd"

func _ready():
	animation_player.play()
	if Global.debug:
		info_label.visible = true
		info_label.text = "GOLDEN: %d" % speed
	food_value = 50
	speed *= 2
	point_value = speed * 2
