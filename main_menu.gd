extends Control

@onready var play_button = get_node("VBoxContainer/PlayButton")
@onready var quit_button = get_node("VBoxContainer/QuitButton")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_high_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://HighScores.tscn")

func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://HowToPlay.tscn")
