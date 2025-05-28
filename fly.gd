extends CharacterBody2D

var random_dir := Vector2.ZERO

# The lower the number, the more often it changes direction
var craziness = randf_range(0.5, 5)

# The more erratic a fly is, the faster it is
var speed : float = (200.0 / craziness)

var is_being_pulled : bool = false

# Change later
var food_value = 10

var collision

@onready var animation_player = get_node("AnimatedSprite2D")

func _ready():
	velocity = Vector2(1,0) * speed
	animation_player.play()

func _physics_process(delta):
	# Get pulled by tongue
	if is_being_pulled:
		global_position = Global.tongueHitBox
		print("FLY:", global_position)
		
		# Get eaten by the Chameleon
		if global_position.distance_to(Global.chameleon.global_position) < 5:
			# Update score
			Global.update_score(10)
			Global.hunger += food_value
			queue_free()
	else:
		collision = move_and_collide(velocity * delta)
		if collision:
			velocity = velocity.bounce(collision.get_normal())

func randomize_direction():
	# Get a random direction
	random_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	velocity = random_dir * speed

	# Create timer of length "craziness" then call randomize_direction()
	await get_tree().create_timer(craziness).timeout
	randomize_direction()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "TongueHitBox":
		is_being_pulled = true
		
		# Ignore bottom border, which normally causes the fly to bounce off
		set_collision_mask_value(1, false)
