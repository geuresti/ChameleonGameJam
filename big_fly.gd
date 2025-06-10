extends "res://fly.gd"

var previously_hit_by_tongue = false
var shader_material: ShaderMaterial

func _ready():
	shader_material = animation_player.material
	
	animation_player.play()
	if Global.debug:
		info_label.visible = true
		info_label.text = "BIG: %d" % speed
	food_value = 35
	speed *= 0.65
	point_value = speed * 1.2

func low_hp_flash():
	var hp_tween = create_tween()
	
	# Infinite loop
	hp_tween.set_loops()
	
	# Color flash
	hp_tween.tween_property(shader_material, "shader_parameter/modulate", Color.WEB_PURPLE, 0.6)
	hp_tween.tween_property(shader_material, "shader_parameter/modulate", Color.MEDIUM_PURPLE, 0.6)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "TongueHitBox":
		print("fartmongus")
		if previously_hit_by_tongue:
			is_being_pulled = true
			# Ignore bottom border, which normally causes the fly to bounce off
			set_collision_mask_value(1, false)
		else:
			previously_hit_by_tongue = true
			low_hp_flash()
