extends Sprite2D

@export var indicator_offset_radius := 85
@export var speed := 1.5
@onready var player_node = get_parent()
@onready var chameleon = get_parent().get_node("Chameleon")
@onready var tongue = get_parent().get_node("Tongue")
@onready var tongue_hitbox = get_parent().get_node("TongueHitBox")
@onready var indicator_tip = get_node("IndicatorTip")
@onready var raycast = get_node("RayCast2D")

var tongue_on_cooldown = false
var cooldown_duration = 0.75
var cooldown_timer = cooldown_duration

var angle_range: float = 60.0

var time := 0.0
var fire_time := 0.0

var is_extending := false
var is_retracting := false

var angle := 0.0
var indicator_offset := Vector2()

const IDLE = 0
const FIRING = 1

var t = 0.0

var tongue_start := Vector2(0, -5)
var tongue_end := Vector2()

@onready var test = get_node("RayCast2D/RayCastCollision")

func _ready():	
	Global.chameleon = chameleon
	Global.tongue_hitbox = tongue_hitbox

func _process(delta):
	# Delay in between shots
	if tongue_on_cooldown:
		cooldown_timer -= delta
		if cooldown_timer < 0:
			tongue_on_cooldown = false
			cooldown_visual_flash()
			cooldown_timer = cooldown_duration
	
	test.global_position = raycast.get_collision_point()
	
	# If not firing and not currently in intermission
	if not is_extending and not is_retracting and not Global.is_intermission:
		# Swing the indicator back and forth while tongue is not extending or retracting
		self.visible = true
		time += delta * speed
		angle = deg_to_rad(sin(time) * angle_range)
		indicator_offset = Vector2(cos(angle - PI / 2), sin(angle - PI / 2)) * indicator_offset_radius
		
		global_position = chameleon.global_position + indicator_offset
		rotation = angle
		
		# Position and rotate the raycast to match the indicator
		var direction = (indicator_tip.global_position - global_position - chameleon.global_position).rotated(deg_to_rad(45))
		raycast.target_position = direction * 700
		
		# Raycast should always be hitting one of the borders
		if raycast.is_colliding():
			tongue_end = raycast.get_collision_point() - chameleon.global_position
	else:
		self.visible = false
	
	# Hide hitbox sprite when not firing
	if not is_extending and not is_retracting:
		tongue_hitbox.visible = false
	else:
		tongue_hitbox.visible = true

	# Tongue extension
	if is_extending:
		tongue_hitbox.set_collision_mask_value(1, true)
		tongue_hitbox.set_collision_layer_value(1, true)
		
		chameleon.frame = FIRING
		
		fire_time += delta
		# Time remaning until the extension is complete
		t = fire_time / Global.extend_duration
	
		# Extension is complete, being retraction
		if t >= 1.0:
			is_extending = false
			is_retracting = true
			fire_time = 0.0
			Global.audio_miss.play(0.25)
		
		# Extend the tongue from the start to end position
		var curr_tongue_tip = tongue_start.lerp(tongue_end, t)
		
		tongue_hitbox.global_position = curr_tongue_tip + chameleon.global_position
		
		tongue.clear_points()
		tongue.add_point(tongue_start)
		tongue.add_point(curr_tongue_tip)
	
	# Tongue retraction
	elif is_retracting:
		tongue_hitbox.set_collision_mask_value(1, false)
		tongue_hitbox.set_collision_layer_value(1, false)
		
		chameleon.frame = IDLE
		fire_time += delta
		
		# Time remaning until the retaction is complete
		t = fire_time / Global.retract_duration
		
		# Retract duration has exceeded
		if t >= 1.0:
			tongue.visible = false
			tongue.clear_points()
			is_retracting = false
			fire_time = 0.0
			tongue_on_cooldown = true
		# Retract tongue
		else:
			# Interpolate between base and tip by animation progress percentage
			var curr_tongue_tip = tongue_start.lerp(tongue_end, 1.0 - t)
			
			tongue_hitbox.global_position = curr_tongue_tip + chameleon.global_position
			
			tongue.clear_points()
			tongue.add_point(tongue_start)
			tongue.add_point(curr_tongue_tip)

func _input(event):
	if event.is_action_pressed("fire_tongue"):
		fire_tongue()
	
	# For testing
	if event.is_action_pressed("ui_down"):
		Global.hunger -= 10
	
	if event.is_action_pressed("ui_up"):
		Global.hunger += 10

func cooldown_visual_flash():
	var cooldown_tween = create_tween()
	# Color flash
	cooldown_tween.tween_property(chameleon, "self_modulate", Color(0, 0.53, 1, 1), 0.3)
	cooldown_tween.tween_property(chameleon, "self_modulate", Color(1, 1, 1, 1), 0.3)

# Fire tongue
func fire_tongue():
	if not is_extending and not is_retracting and not Global.is_intermission and not tongue_on_cooldown and Global.playing:
		is_extending = true
		fire_time = 0.0
		tongue.visible = true
		Global.audio_tongue_shot.play()

# Fly caught by tongue
func _on_tongue_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "FlyHitbox":
		is_extending = false
		is_retracting = true
		fire_time = 0.0
		tongue_end = area.global_position - global_position
		Global.audio_tongue_retract.play()
