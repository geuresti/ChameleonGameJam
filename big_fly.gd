extends "res://fly.gd"

var previously_hit_by_tongue = false

func _ready():
	animation_player.play()
	if Global.debug:
		info_label.visible = true
		info_label.text = "BIG: %d" % speed
	food_value = 40
	speed *= 0.65
	point_value = speed * 1.2

func start_flashing():
	var tween = create_tween()
	
	# Infinite loop
	tween.set_loops()
		
	# Color flash
	tween.tween_property(animation_player, "modulate", Color.AQUA, 0.4)
	tween.tween_property(animation_player, "modulate", Color(1, 1, 1, 1), 0.4)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "TongueHitBox":
		if previously_hit_by_tongue:
			is_being_pulled = true
			# Ignore bottom border, which normally causes the fly to bounce off
			set_collision_mask_value(1, false)
		else:
			previously_hit_by_tongue = true
			start_flashing()
