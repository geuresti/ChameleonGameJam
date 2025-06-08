extends Node

var chameleon : AnimatedSprite2D = null

var score := 0
var hunger := 100.0
var hunger_rate := 4
var wave := 0

var difficulty = 1

var debug = false

var retract_duration := 0.5
var extend_duration = 1.0

@onready var score_label = get_node("/root/Main/HUD/Score")
@onready var wave_label = get_node("/root/Main/HUD/Wave")

@onready var hunger_bar = get_node("/root/Main/HUD/HungerBar")

var tongue_start: Vector2
var tongue_end: Vector2

var tongue_hitbox: Area2D

var tongue_offset = 18

var is_intermission = false
var pause_hunger = false

var audio_player

func _ready():
	hunger_bar.value = 100

func _process(delta):
	if hunger > 0 and not is_intermission and not pause_hunger:
		hunger -= hunger_rate * delta
		hunger = max(hunger, 0)
		hunger_bar.value = hunger
	else:
		game_over()

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

func freeze_hunger(seconds_amount):
	pause_hunger = true
	await get_tree().create_timer(seconds_amount).timeout
	pause_hunger = false

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

func game_over():
	#print("GAME OVER")
	pass
