extends Control

@onready var score_labels = $VBoxContainer.get_children()
var high_scores

func _ready():
	update_score_display()

func update_score_display():
	high_scores = Global.get_high_scores()
	for i in range(high_scores.size()):
		score_labels[i].text = "%d.              %s" % [i + 1, str(int(high_scores[i]))]

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
