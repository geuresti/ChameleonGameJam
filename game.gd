extends Node2D

var fly_scene = preload("res://Fly.tscn")

@onready var fly_spawn_area = get_node("FlySpawnArea/FlySpawnAreaShape")
@onready var fly_spawner = get_node("FlySpawner")

@onready var spawn_area_size = fly_spawn_area.shape.extents

@onready var x_start = fly_spawn_area.global_position.x - spawn_area_size.x
@onready var x_end = fly_spawn_area.global_position.x + spawn_area_size.x

@onready var y_start = fly_spawn_area.global_position.y - spawn_area_size.y
@onready var y_end = fly_spawn_area.global_position.y + spawn_area_size.y

@onready var timer_label = get_node("/root/Main/HUD/Timer")

@onready var border_left = get_node("Borders/LeftBorder")
@onready var border_top = get_node("Borders/TopBorder")
@onready var border_right = get_node("Borders/RightBorder")

@onready var intermission_label = get_node("HUD/Intermission")

var dist_left : float
var dist_top : float
var dist_right : float

var flies_per_wave

var intermission_duration = 6
var intermission_timer
var start_intermission_timer = false

var wave_duration = 26
var wave_timer

var flies = []

const LEFT = 0
const TOP = 1
const RIGHT = 2

var x : float
var y : float
var target : Vector2

func _ready():
	start_wave()
	wave_timer = wave_duration
	intermission_timer = intermission_duration
	intermission_label.visible = false

func _process(delta):
	if Global.is_intermission and start_intermission_timer:
		intermission_label.text = "Next Wave In: %ds" % intermission_timer
		intermission_timer -= delta
		
		if intermission_timer < 0:
			intermission_label.visible = false
			start_wave()
			intermission_timer = intermission_duration
	
	# Wave timer and label logic
	elif wave_timer > 0:
		timer_label.text = "Time Remaining: %ds" % wave_timer
		wave_timer -= delta
	
	# If the wave timer hit 0 or all the flies were caught
	if (wave_timer < 0 and not Global.is_intermission) or (fly_spawner.get_child_count() == 0 and not Global.is_intermission):
		Global.is_intermission = true
		end_wave()

func get_random_stage_pos():
	x = randf_range(x_start, x_end)
	y = randf_range(y_start, y_end)
	return Vector2(x, y)

# CURRENTLY UNUSED
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
	
	# Random int 0, 1, 2
	var random_edge = randi() % 3
	
	match(random_edge):
		LEFT:
			return Vector2(-100, fly_pos.y)
		TOP:
			return Vector2(border_right.global_position.x + 100, fly_pos.y)
		RIGHT:
			return Vector2(fly_pos.x, -100)

func get_random_spawn_position():
	# Random int 0, 1, 2
	var random_edge = randi() % 3
	var random_val
	
	match(random_edge):
		LEFT:
			random_val = randf_range(0, 420)
			return Vector2(-100, random_val)
		TOP:
			random_val = randf_range(100, 1000)
			return Vector2(random_val, -100)
		RIGHT:
			random_val = randf_range(0, 420)
			return Vector2(1300, random_val)

# Free all the objects and reset the array
func clear_flies():
	for fly in flies:
		if is_instance_valid(fly):
			fly.queue_free()
	flies.clear()

func start_wave():
	Global.wave += 1
	Global.update_wave_label()
	wave_timer = wave_duration
	
	# MIN 6, add more depending on how low on food the player is? w wiggle room. ?
	flies_per_wave = 6
	
	for i in flies_per_wave:
		var fly = fly_scene.instantiate()
		fly_spawner.add_child(fly)
		fly.global_position = get_random_spawn_position()
		
		# Get a random position in the spawn area
		target = get_random_stage_pos()
		
		# The fly will move to the target
		fly.move_to(target)
		
		# initialize fly movement
		fly.randomize_direction()
		
		flies.append(fly)
	
	await get_tree().create_timer(1.0).timeout
	Global.is_intermission = false
	start_intermission_timer = false

func end_wave():
	for fly in flies:
		if is_instance_valid(fly):
			fly.move_to(get_random_edge_pos(fly.global_position))
	
	# ! Not sure this actually works.
	Global.tongue_hitbox.visible = false
	
	# Give any remaining flies time to leave the screen
	await get_tree().create_timer(1.5).timeout
	
	clear_flies()
	
	Global.difficulty += 1
	start_intermission_timer = true
	intermission_label.visible = true
