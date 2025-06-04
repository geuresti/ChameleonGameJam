extends Node

var chameleon : AnimatedSprite2D = null

var score := 0
var hunger := 100.0
var hunger_rate := 5.0
var wave := 0

@onready var score_label = get_node("/root/Main/HUD/Score")
@onready var wave_label = get_node("/root/Main/HUD/Wave")

@onready var hunger_bar = get_node("/root/Main/HUD/HungerBar")

var tongue_start: Vector2
var tongue_end: Vector2

var tongueHitBox: Vector2

func _ready():
	hunger_bar.value = 100

func _process(delta):
	
	if hunger > 0:
		hunger -= hunger_rate * delta
		hunger = max(hunger, 0)
		hunger_bar.value = hunger
	else:
		game_over()

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
