extends Node2D

const TRAMPLED_TOMATOES = preload("res://assets/environment/props/trampled-tomatoes.png")

@onready var lbl_state = $Player/Camera2D/LblState
@onready var player = $Player
@onready var dialogue_ui = $Player/Camera2D/DialogueUi
@onready var tomatoes = $Tomatoes
@onready var dialogue_trigger = $DialogueTrigger/CollisionShape2D
@onready var background_sprite = %BackgroundSprite
@onready var tree_sprite = %TreeSprite

var state_name

# trample timers
var start_trample_timer = false
var time_after_trample = 1.0
var trample_timer = 0
var disable_trample_timer = false

func _ready():
	dialogue_trigger.set_deferred('disabled', true)

func _process(delta):
	state_name = player.getStateForLabel()
	lbl_state.set_text(state_name)
	
	if start_trample_timer and not disable_trample_timer:
		trample_timer += delta
		if trample_timer >= time_after_trample:
			dialogue_trigger.set_deferred('disabled', false)
			disable_trample_timer = true

func _on_btn_return_pressed():
	get_tree().change_scene_to_file('res://script/scenes/main_menu.tscn')

func _on_area_2d_area_entered(area):
	if state_name == 'Falling' or state_name == 'Falling Faster':
		start_trample_timer = true
		tomatoes.texture = TRAMPLED_TOMATOES
