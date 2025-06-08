extends "res://fly.gd"

func _ready():
	animation_player.play()
	if Global.debug:
		info_label.visible = true
		info_label.text = "GOLDEN: %d" % speed
	food_value = 30
	speed = max(speed * 2, 600)
	point_value = speed * 1.5
