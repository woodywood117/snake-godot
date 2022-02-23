extends Control

func _on_Button_pressed():
	var game_scene = load("res://Game.tscn")
	get_tree().change_scene_to(game_scene)
