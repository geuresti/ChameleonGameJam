extends Sprite2D

@export var radius: int = 50
@export var speed: int = 1

@onready var player_node = get_parent()
@onready var chameleon = get_parent().get_node("Chameleon")
@onready var tongue = get_parent().get_node("Tongue")

@onready var tongue_hitbox = get_parent().get_node("TongueHitBox")

@onready var indicator_tip = get_node("IndicatorTip")

@onready var raycast = get_node("RayCast2D")

var angle_range: float = 60.0

var time := 0.0
var fire_time := 0.0

var is_extending := false
var is_retracting := false

var angle := 0.0
var indicator_offset := Vector2()

const IDLE = 0
const FIRING = 1

var extend_duration := 1.0
var retract_duration := 0.3

#var tongue_start := Vector2()
var tongue_start := Vector2.ZERO

var tongue_end := Vector2()

func _ready():
	# Add to singleton to make it globally accessible
	Global.chameleon = chameleon

func _process(delta):
	# Swing the indicator back and forth while tongue is not extending or retracting
	if not is_extending and not is_retracting:
		self.visible = true
		time += delta * speed
		angle = deg_to_rad(sin(time) * angle_range)
		indicator_offset = Vector2(cos(angle - PI / 2), sin(angle - PI / 2)) * radius
		
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

	# Tongue extension
	if is_extending:
		chameleon.frame = FIRING
		
		fire_time += delta
		# Time remaning until the extension is complete
		var t = fire_time / extend_duration
	
		# Extension is complete, being retraction
		if t >= 1.0:
			is_extending = false
			is_retracting = true
			fire_time = 0.0
		
		# Extend the tongue from the start to end position
		var curr_tongue_tip = tongue_start.lerp(tongue_end, t)
		
		tongue_hitbox.global_position = curr_tongue_tip + chameleon.global_position
		
		tongue.clear_points()
		tongue.add_point(tongue_start)
		tongue.add_point(curr_tongue_tip)
	
	# Tongue retraction
	elif is_retracting:
		chameleon.frame = IDLE
		fire_time += delta
		
		# Time remaning until the retaction is complete
		var t = fire_time / retract_duration

		# Retract duration has exceeded
		if t >= 1.0:
			tongue.visible = false
			tongue.clear_points()
			is_retracting = false
			fire_time = 0.0
		# Retract tongue
		else:
			# Interpolate between bease and tip by animation progress percentage
			var curr_tongue_tip = tongue_start.lerp(tongue_end, 1.0 - t)
			
			tongue_hitbox.global_position = curr_tongue_tip + chameleon.global_position
			
			tongue.clear_points()
			tongue.add_point(tongue_start)
			tongue.add_point(curr_tongue_tip)

func _input(event):
	if event.is_action_pressed("fire_tongue"):
		fire_tongue()
	if event.is_action_pressed("ui_down"):
		print("ui down")
		tongue.clear_points()

# Fire tongue
func fire_tongue():
	if not is_extending and not is_retracting:
		#Global.tongue_start = tongue_start + chameleon.global_position
		#Global.tongue_end = tongue_end + chameleon.global_position
		is_extending = true
		fire_time = 0.0
		tongue.visible = true

# Fly caught by tongue
func _on_tongue_hit_box_area_entered(area: Area2D) -> void:
	if area.name == "FlyHitbox":
		is_extending = false
		is_retracting = true
		fire_time = 0.0
		#tongue_hitbox.global_position = tongue_end + chameleon.global_position
