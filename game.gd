extends Node2D

@onready var fly_spawn_area = get_node("FlySpawnArea/FlySpawnAreaShape")
@onready var fly_spawner = get_node("FlySpawner")

@onready var spawn_area_size = fly_spawn_area.shape.extents

@onready var x_start = fly_spawn_area.global_position.x - spawn_area_size.x
@onready var x_end = fly_spawn_area.global_position.x + spawn_area_size.x

@onready var y_start = fly_spawn_area.global_position.y - spawn_area_size.y
@onready var y_end = fly_spawn_area.global_position.y + spawn_area_size.y

@onready var timer_label = get_node("/root/Main/HUD/Timer")
@onready var wave_label = get_node("/root/Main/HUD/Wave")
@onready var score_label = get_node("/root/Main/HUD/Score")
@onready var hunger_bar = get_node("/root/Main/HUD/HungerBar")
@onready var hud_background = get_node("/root/Main/HUD/HUD_BG")
@onready var player = get_node("Player")

@onready var border_left = get_node("Borders/LeftBorder")
@onready var border_top = get_node("Borders/TopBorder")
@onready var border_right = get_node("Borders/RightBorder")
@onready var border_bottom = get_node("StaticBody2D")

@onready var intermission_label = get_node("HUD/Intermission")

@onready var audio_consume = get_node("AudioConsume")
@onready var audio_tongue_shot = get_node("AudioTongueShot")
@onready var audio_tongue_retract = get_node("AudioTongueRetract")
@onready var audio_lose = get_node("AudioLose")
@onready var audio_miss = get_node("AudioMiss")
@onready var audio_background_music = get_node("AudioBackgroundMusic")

@onready var game_over_overlay = get_node("GameOverOverlay/ColorRect")
@onready var game_over_overlay_text = get_node("GameOverOverlay/VBoxContainer")

var dist_left : float
var dist_top : float
var dist_right : float

var flies_per_wave

var intermission_duration = 6
var intermission_timer = intermission_duration
var start_intermission_timer = false

var wave_duration = 36
var wave_timer = wave_duration

var flies = []

var level_clear = false

var min_flies = 6
var max_flies = 11

const LEFT = 0
const TOP = 1
const RIGHT = 2

var x : float
var y : float
var target : Vector2

var normal_fly = preload("res://Fly.tscn")
var poison_fly = preload("res://PoisonFly.tscn")
var golden_fly = preload("res://GoldenFly.tscn")
var fast_fly = preload("res://FastFly.tscn")
var big_fly = preload("res://BigFly.tscn")

var fly_variants = [normal_fly, poison_fly, golden_fly, fast_fly, big_fly]
var fly_weights = [1.5, 0.3, 0.1, 0.4, 0.4]
var rng = RandomNumberGenerator.new()

func _ready():
	intermission_label.visible = false
	intermission_label.modulate.a = 0.0
	
	Global.wave = 0
	
	Global.audio_consume = audio_consume
	Global.audio_tongue_shot = audio_tongue_shot
	Global.audio_tongue_retract = audio_tongue_retract
	Global.audio_lose = audio_lose
	Global.audio_miss = audio_miss
	Global.audio_background_music = audio_background_music
	
	Global.fly_spawner = fly_spawner
	
	Global.timer_label = timer_label
	Global.wave_timer = wave_timer
	
	Global.score_label = score_label
	Global.wave_label = wave_label
	Global.hunger_bar = hunger_bar
	Global.hunger_bar.value = 100
	
	game_over_overlay.self_modulate.a = 0.0
	game_over_overlay_text.modulate.a = 0.0
	
	score_label.modulate.a = 0.0
	timer_label.modulate.a = 0.0
	wave_label.modulate.a = 0.0
	
	hud_background.self_modulate.a = 0.0
	hunger_bar.self_modulate.a = 0.0
	player.modulate.a = 0.0
	border_bottom.global_position.x = -1200.0
	
	fade_in_UI()

	Global.playing = true
	# Starting with is_intermission = true prevents _process from ending
	# the wave immediately due to zero flies
	Global.is_intermission = true
	
	await get_tree().create_timer(1.5).timeout
	start_wave()

func _process(delta):
	if Global.playing:
		if Global.hunger <= 0:
			Global.playing = false
			game_over()
	
		if Global.is_intermission and start_intermission_timer:
			intermission_label.text = "Next Wave In: %ds" % intermission_timer
			intermission_timer -= delta
			
			if intermission_timer < 0:
				start_intermission_timer = false
				start_wave()
		
		# Wave timer and label logic
		elif wave_timer > 0 and not Global.is_intermission:
			timer_label.text = "Time Remaining: %ds" % wave_timer
			wave_timer -= delta
		
		# If the wave timer hit 0 or all the flies were caught
		if not Global.is_intermission:
			if (wave_timer < 0) or (Global.level_cleared):
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

# Return the number of flies that should spawn.
# This function will return 6 - 12, depending how much hunger is missing.
# If hunger <= 25, the max number of flies will spawn.
func calculate_number_of_flies():
	var hunger_ratio = clamp(float(100 - Global.hunger) / 75, 0.0, 1.0)
	var num_flies_to_spawn = int(round(lerp(min_flies, max_flies, hunger_ratio)))
	return num_flies_to_spawn

# Choose a random fly variant based on their weights
func pick_random_fly():
	var random_fly = fly_variants[rng.rand_weighted(fly_weights)]
	return random_fly

func start_wave():
	# Fade text opacity to 0
	var tween = create_tween()
	tween.tween_property(intermission_label, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN_OUT)
	
	# Give the text time to fade out before toggling visiblity
	await get_tree().create_timer(0.5).timeout
	intermission_label.visible = false
	
	# Reset intermission timer
	intermission_timer = intermission_duration
	
	# Update wave value and label
	Global.wave += 1
	Global.update_wave_label()
	wave_timer = wave_duration
	
	# Determine how many flies to spawn
	flies_per_wave = calculate_number_of_flies()
	
	var fly
	
	# Spawn flies
	for i in flies_per_wave:
		fly = pick_random_fly().instantiate()
		
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
	Global.level_cleared = false
	Global.is_intermission = false

func end_wave():
	for fly in flies:
		if is_instance_valid(fly):
			fly.move_to(get_random_edge_pos(fly.global_position))
	
	# ! Not sure this actually works.
	Global.tongue_hitbox.visible = false
	
	# Increase the score based on remaining time
	if wave_timer > 0:
		Global.wave_timer = wave_timer
		Global.animate_wave_timer()
		Global.update_score(wave_timer * 100)
	
	# Give any remaining flies time to leave the screen
	await get_tree().create_timer(1.5).timeout
	
	clear_flies()
	
	Global.difficulty += 1
	start_intermission_timer = true
	
	# Tween the opacity for the label to fade text in
	var tween = create_tween()
	intermission_label.visible = true
	tween.tween_property(intermission_label, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_IN_OUT)

func game_over():
	audio_lose.play()
	var tween = create_tween()
	tween.tween_property(game_over_overlay, "self_modulate:a", 1.0, 0.5)
	tween.tween_property(game_over_overlay_text, "modulate:a", 1.0, 0.5)
	Global.playing = false

var fade_in_time = 0.2
func fade_in_UI():
	var tween = create_tween()
	tween.tween_property(border_bottom, "position:x", 0.0, 0.5)
	tween.tween_property(hud_background, "self_modulate:a", 1.0, fade_in_time)
	
	tween.tween_property(score_label, "modulate:a", 1.0, fade_in_time)
	tween.tween_property(wave_label, "modulate:a", 1.0, fade_in_time)
	tween.tween_property(timer_label, "modulate:a", 1.0, fade_in_time)
	
	tween.tween_property(player, "modulate:a", 1.0, fade_in_time)
	tween.tween_property(hunger_bar, "self_modulate:a", 1.0, fade_in_time)

func _on_play_button_pressed() -> void:
	Global.hunger = 100
	Global.score = 0
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	Global.hunger = 100
	Global.score = 0
	get_tree().change_scene_to_file("res://MainMenu.tscn")
