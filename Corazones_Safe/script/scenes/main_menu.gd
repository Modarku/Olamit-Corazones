extends Node2D

func _on_btn_play_pressed():
	get_tree().change_scene_to_file('res://script/scenes/scene_worldone.tscn')

func _on_btn_state_pressed():
	get_tree().change_scene_to_file('res://script/scenes/scene_state_machine.tscn')

func _on_btn_quit_pressed():
	get_tree().quit()
