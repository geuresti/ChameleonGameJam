extends Node2D

var fly_scene = preload("res://Fly.tscn")

@onready var fly_spawn_area = get_node("FlySpawnArea/FlySpawnAreaShape")

@onready var spawn_area_size = fly_spawn_area.shape.extents

@onready var x_start = fly_spawn_area.global_position.x - spawn_area_size.x
@onready var x_end = fly_spawn_area.global_position.x + spawn_area_size.x

@onready var y_start = fly_spawn_area.global_position.y - spawn_area_size.y
@onready var y_end = fly_spawn_area.global_position.y + spawn_area_size.y

@onready var timer_label = get_node("/root/Main/HUD/Timer")

@onready var border_left = get_node("Borders/LeftBorder")
@onready var border_top = get_node("Borders/TopBorder")
@onready var border_right = get_node("Borders/RightBorder")

var dist_left : float
var dist_top : float
var dist_right : float

var flies_per_wave = 12
var wave_delay = 3
var wave_duration = 4

var wave_timer = 0.0
var wave_active = false
var flies = []

const LEFT = 0
const TOP = 1
const RIGHT = 2

var x : float
var y : float
var target : Vector2

func _ready():
	#start_wave()
	wave_timer = wave_duration

func _process(delta):
	# Wave timer and label logic
	if wave_active:
		timer_label.text = "Time Remaining: %ds" % wave_timer
		wave_timer -= delta
	
	# The wave timer hit 0
	if wave_timer < 0 and wave_active:
		end_wave()

func get_random_stage_pos():
	x = randf_range(x_start, x_end)
	y = randf_range(y_start, y_end)
	return Vector2(x, y)

func get_closest_edge_pos(fly_pos):
	dist_left = fly_pos.distance_to(border_left.global_position)
	dist_top = fly_pos.distance_to(border_top.global_position)
	dist_right = fly_pos.distance_to(border_right.global_position)

	var closest_edge = min(dist_left, dist_top, dist_right)
	
	if closest_edge == dist_left:
		#return Vector2(border_left.global_position.x, fly_pos.y)
		return Vector2(-100, fly_pos.y)
	elif closest_edge == dist_right:
		return Vector2(border_right.global_position.x + 100, fly_pos.y)
	else:
		return Vector2(fly_pos.x, -100)

func get_random_edge_pos(fly_pos):
	var random_edge = randi() % 3
	
	match(random_edge):
		LEFT:
			return Vector2(-100, fly_pos.y)
		TOP:
			return Vector2(border_right.global_position.x + 100, fly_pos.y)
		RIGHT:
			return Vector2(fly_pos.x, -100)

# Free all the objects and reset the array
func clear_flies():
	for fly in flies:
		fly.queue_free()
	flies.clear()

func start_wave():
	wave_active = true
	clear_flies()
	
	Global.wave += 1
	Global.update_wave_label()
	wave_timer = wave_duration
	
	for i in flies_per_wave:
		var fly = fly_scene.instantiate()
		add_child(fly)
		
		# Get a random position in the spawn area
		target = get_random_stage_pos()
		
		# The fly will move to the target
		fly.move_to(target)
		
		# initialize fly movement
		fly.randomize_direction()
		
		flies.append(fly)

func end_wave():
	# chameleon cannot fire
	wave_active = false

	var remaining_flies = []
	
	# Remove freed flies
	for fly in flies:
		if is_instance_valid(fly):
			remaining_flies.append(fly)
	
	flies = remaining_flies
	
	for fly in flies:
		#fly.move_to(get_closest_edge_pos(fly.global_position))
		fly.move_to(get_random_edge_pos(fly.global_position))
		
	await get_tree().create_timer(wave_delay).timeout
	start_wave()
