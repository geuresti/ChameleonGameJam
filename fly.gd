extends Area2D

func _on_area_entered(area: Area2D) -> void:
	#print(area.name)
	if area.name == "TongueHitBox":
		print("HIT!")
		queue_free()
