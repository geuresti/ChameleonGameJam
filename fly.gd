extends CharacterBody2D

var random_dir := Vector2.ZERO

# The lower the number, the more often it changes direction
var craziness = randf_range(0.5, 5)

var speed_median : float = 30 * (Global.difficulty * 0.75)

# The more erratic a fly is, the faster it is
var speed = randf_range(speed_median * 0.7, speed_median * 1.3) 

var is_being_pulled : bool = false

var food_value = 15
var point_value = speed

var collision

#var tween = get_tree().create_tween()
var tween: Tween = null

@onready var animation_player = get_node("AnimatedSprite2D")
@onready var info_label = get_node("Info")

func _ready():
	# Hardcoded rightward movement for testing
	#velocity = Vector2(1,0) * speed
	#randomize_direction()
	animation_player.play()
	info_label.text = "SPEED: %d" % speed

func _physics_process(delta):	
	# Get pulled by tongue
	if is_being_pulled:
		
		# If the fly is caught during the intermission, kill the tween
		if tween and tween.is_running():
			tween.kill()
			tween = null
		
		# Move the fly to the chameleon in retract_duration seconds
		global_position = Global.tongue_hitbox.global_position
		if global_position.distance_to(Global.chameleon.global_position) < 20:
			# Update score
			#Global.update_score(10)
			Global.hunger += food_value
			Global.update_score(point_value)
			queue_free()
	else:
		collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal())

func randomize_direction():
	# Set fly to be able to collide with the borders
	set_collision_mask_value(1, true)
	
	# Get a random direction
	random_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	velocity = random_dir * speed

func move_to(pos: Vector2, time : float = 1.0) -> void:
	# Tween for fly position
	tween = get_tree().create_tween()
	tween.tween_property(self, "position", pos, time)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "TongueHitBox":
		is_being_pulled = true
		# Ignore bottom border, which normally causes the fly to bounce off
		set_collision_mask_value(1, false)
