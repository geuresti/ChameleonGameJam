extends Node2D

var flies_per_wave = 5
var wave_delay = 3
var wave_duration = 10

var fly_scene = preload("res://Fly.tscn")

@onready var fly_spawn_area = get_node("FlySpawnArea/FlySpawnAreaShape")

@onready var spawn_area_size = fly_spawn_area.shape.extents

@onready var x_start = fly_spawn_area.global_position.x - spawn_area_size.x
@onready var x_end = fly_spawn_area.global_position.x + spawn_area_size.x

@onready var y_start = fly_spawn_area.global_position.y - spawn_area_size.y
@onready var y_end = fly_spawn_area.global_position.y + spawn_area_size.y

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
	start_wave()

func get_random_stage_pos():
	x = randf_range(x_start, x_end)
	y = randf_range(y_start, y_end)
	return Vector2(x, y)

func get_random_edge_pos():
	
	var side = randi_range(0, 2)
	
	# get_viewport().size.x
	
	if side == LEFT:
		print("left side")
		
	elif side == TOP:
		print("top side")
		
	else:
		print("right side")
	
	return Vector2.ZERO

func start_wave():
	wave_active = false
	flies.clear()
	
	for i in flies_per_wave:
		var fly = fly_scene.instantiate()
		add_child(fly)
		
		#get_random_edge_pos()
		target = get_random_stage_pos()
		print("TARGET ACQUIRED:", target)
		
		fly.move_to(target)
		
		# initialize fly movement
		fly.randomize_direction()
		
		#fly.global_position = ...
		flies.append(fly)

func end_wave():
	# chameleon cannot fire
	# wave_active = false *
	
	for fly in flies:
		# move to nearest edge
		pass
		
	#await get_tree().create_timer(2.0).timeout
	#start_wave()
