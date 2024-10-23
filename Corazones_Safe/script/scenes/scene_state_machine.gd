extends Node2D

@onready var state_nodes = $StateMachine/StateNodes
@onready var inputs_idle = $StateMachine/InputsIdle
@onready var inputs_move = $StateMachine/InputsMove
@onready var inputs_jump = $StateMachine/InputsJump
@onready var inputs_fall = $StateMachine/InputsFall
@onready var inputs_fall_fast = $StateMachine/InputsFallFast
@onready var inputs_hold_wall = $StateMachine/InputsHoldWall
@onready var inputs_dash = $StateMachine/InputsDash

@onready var legend_states = $States
@onready var legend_inputs = $Inputs
var is_states = false
var is_inputs = false

var inputs

func _ready():
	legend_inputs.visible = false
	legend_states.visible = false
	
	inputs = [
		inputs_idle, inputs_move, inputs_jump, inputs_fall, 
		inputs_fall_fast, inputs_hold_wall, inputs_dash
		]
	
	for input in inputs:
		input.set_modulate('ffffff20')

func _on_btn_back_pressed():
	get_tree().change_scene_to_file('res://script/scenes/main_menu.tscn')

# SHOW INPUTS BUTTONS
func _on_idle_mouse_entered():
	inputs_idle.set_modulate('ffffff')
func _on_idle_mouse_exited():
	inputs_idle.set_modulate('ffffff20')

func _on_move_mouse_entered():
	inputs_move.set_modulate('ffffff')
func _on_move_mouse_exited():
	inputs_move.set_modulate('ffffff20')

func _on_jump_mouse_entered():
	inputs_jump.set_modulate('ffffff')
func _on_jump_mouse_exited():
	inputs_jump.set_modulate('ffffff20')

func _on_fall_mouse_entered():
	inputs_fall.set_modulate('ffffff')
func _on_fall_mouse_exited():
	inputs_fall.set_modulate('ffffff20')

func _on_fall_fast_mouse_entered():
	inputs_fall_fast.set_modulate('ffffff')
func _on_fall_fast_mouse_exited():
	inputs_fall_fast.set_modulate('ffffff20')

func _on_hold_wall_mouse_entered():
	inputs_hold_wall.set_modulate('ffffff')
func _on_hold_wall_mouse_exited():
	inputs_hold_wall.set_modulate('ffffff20')

func _on_dash_mouse_entered():
	inputs_dash.set_modulate('ffffff')
func _on_dash_mouse_exited():
	inputs_dash.set_modulate('ffffff20')

func _on_btn_states_pressed():
	legend_states.visible = false if is_states else true
	legend_inputs.visible = true if is_states else false

func _on_btn_inputs_pressed():
	legend_inputs.visible = false if is_states else true
	legend_states.visible = true if is_states else false
