extends Sprite2D

@export var radius: int = 50
@export var speed: int = 2
@export var angle_range: float = 60.0

@onready var player_node = get_parent()
@onready var chameleon = get_parent().get_node("Chameleon")
@onready var tongue = get_parent().get_node("Tongue")

@onready var indicator_tip = get_node("IndicatorTip")

var time := 0.0
var is_firing := true
var fire_time := 0.0

var shot_duration := 1 

var angle := 0.0
var indicator_offset := Vector2()
var frozen_direction := Vector2()

func _process(delta):
	time += delta * speed
	angle = deg_to_rad(sin(time) * angle_range)
	indicator_offset = Vector2(cos(angle - PI / 2), sin(angle - PI / 2)) * radius
	
	if is_firing:
		fire_time += delta
		#tongue.add_point(indicator_tip.position)
		tongue.add_point(Vector2(0,0)) # Looks a bit better, angle is more in line w indicator
		tongue.add_point((global_position - chameleon.global_position) * 3) 
		
		# Reset tongue after shot ends
		if fire_time >= shot_duration:
			is_firing = false
			tongue.visible = false
			tongue.clear_points()
			fire_time = 0.0
	else:
		global_position = chameleon.global_position + indicator_offset
		rotation = angle

func _input(event):
	if event.is_action_pressed("fire_tongue"):
		fire_tongue()

func fire_tongue():
	print("tongue is fired")
	is_firing = true
	fire_time = 0.0
	tongue.visible = true
