extends Node

var chameleon : AnimatedSprite2D = null

var score := 0
var hunger := 100.0
var hunger_rate := 3.5
var wave := 0

var difficulty = 1

var debug = false

var retract_duration := 0.5
var extend_duration = 1.0

var score_label
var wave_label
var hunger_bar

var timer_label
var wave_timer
var animating_timer = false

var tongue_start: Vector2
var tongue_end: Vector2

var tongue_hitbox: Area2D

var tongue_offset = 24

var is_intermission = false
var pause_hunger = false

var hunger_flashing = false
var hunger_flash_tween: Tween

var audio_consume: AudioStreamPlayer2D
var audio_tongue_shot: AudioStreamPlayer2D

var audio_tongue_retract: AudioStreamPlayer2D
var audio_miss: AudioStreamPlayer2D
var audio_lose: AudioStreamPlayer2D
var audio_background_music: AudioStreamPlayer2D

var fly_spawner: Node2D

var playing = false
var level_cleared := false

const SAVEFILE = "user://scores.save"
var high_scores = []

func _init():
	load_high_scores()

func _process(delta):
	if playing:
		if hunger > 0:
			if not is_intermission and not pause_hunger:
				hunger -= hunger_rate * delta
				hunger = max(hunger, 0)
				hunger_bar.value = hunger
				
			# Make the hunger bar flash when low
			if hunger < 25:
				if not hunger_flashing:
					hunger_flashing = true
					low_hunger_flash()
			else:
				# Pause the hunger bar flash
				hunger_flashing = false
				if hunger_flash_tween:
						hunger_flash_tween.kill()
						# Reset the color
						hunger_bar.modulate = Color(1, 1, 1, 1)
		#else:
		#	game_over()

func update_hunger(food_value):
	var tween = create_tween()
	var new_value
	var pause_length

	if (hunger + food_value > 100):
		new_value = 100
		pause_length = 3
	else:
		new_value = hunger + food_value
		pause_length = 2
	
	hunger = new_value
	tween.tween_property(hunger_bar, "value", hunger, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Pause the hunger bar temporarily
	Global.freeze_hunger(pause_length)

func animate_wave_timer():
	if wave_timer > 0:
		var tween = create_tween()
		tween.tween_method(_update_countdown, wave_timer, 0.0, 1)
		tween.tween_callback(Callable(self, "_on_countdown_finished"))
		
func _update_countdown(value: float) -> void:
	timer_label.text = "Time Remaining: %ds" % int(ceil(value))

func freeze_hunger(seconds_amount):
	pause_hunger = true
	await get_tree().create_timer(seconds_amount).timeout
	pause_hunger = false

func low_hunger_flash():
	hunger_flash_tween = create_tween()

	# Infinite loop
	hunger_flash_tween.set_loops()
	
	# Color flash
	hunger_flash_tween.tween_property(hunger_bar, "modulate", Color.RED, 0.3)
	hunger_flash_tween.tween_property(hunger_bar, "modulate", Color(1, 1, 1, 1), 0.3)

func update_score(points):
	# Blow up the label size
	score_label.scale = Vector2(1.5, 1.5)
	
	# Change label to green
	score_label.modulate = Color(0, 1, 0)
	
	# Tween for numerical animation
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(score_label, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(score_label, "modulate", Color(1, 1, 1), 0.2)
	tween.parallel().tween_method(Callable(self, "update_score_label"), score, (score + points), 0.3)
	
	score += points

func update_score_label(new_score):
	score_label.text = "Score: %d" % new_score

func update_wave_label():
	wave_label.text = "Wave: %d" % wave

# Check if the level is cleared after a brief delay to give flies time to be removed
func check_if_level_cleared_helper():
	await get_tree().create_timer(0.25).timeout
	level_cleared = check_if_level_cleared()

# The level is clear when there are no flies remaining OR when the only flies left are poisonous
func check_if_level_cleared():
	if fly_spawner.get_child_count() == 0:
		return true
	else:
		for fly in fly_spawner.get_children():
			if fly is not PoisonFly:
				return false
		return true

func load_high_scores():
	var file = FileAccess.open(SAVEFILE, FileAccess.READ)
	if file:
		var data = file.get_as_text()
		high_scores = JSON.parse_string(data)
		file.close()
	else:
		high_scores = []

func save_high_scores():
	var file = FileAccess.open(SAVEFILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(high_scores))
	file.close()

func add_new_score():
	high_scores.append(int(score))
	high_scores.sort()
	high_scores.reverse()
	high_scores = high_scores.slice(0, 5)
	save_high_scores()

func get_high_scores():
	return high_scores
