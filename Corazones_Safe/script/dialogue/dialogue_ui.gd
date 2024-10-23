extends CanvasLayer

@onready var character_name = $Name
@onready var character_dialogue = $Dialogue
@onready var sprite_texture = $SpriteTexture
@onready var seeds = %Seeds
@onready var player = %Player

const VALUE = 'mood'

const BLAIR_AGITATED = preload("res://assets/dialogue/characters/blair_agitated.png")
const BLAIR_EXPLAINING = preload("res://assets/dialogue/characters/blair_explaining.png")
const BLAIR_MAD = preload("res://assets/dialogue/characters/blair_mad.png")
const BLAIR_NEUTRAL = preload("res://assets/dialogue/characters/blair_neutral.png")
const BLAIR_SIGH = preload("res://assets/dialogue/characters/blair_sigh.png")
const BLAIR_UP = preload("res://assets/dialogue/characters/blair_up.png")
const LUCA_APOLOGETIC = preload("res://assets/dialogue/characters/luca_apologetic.png")
const LUCA_HAPPY = preload("res://assets/dialogue/characters/luca_happy.png")
const LUCA_NEUTRAL = preload("res://assets/dialogue/characters/luca_neutral.png")
const LUCA_QUESTIONING = preload("res://assets/dialogue/characters/luca_questioning.png")

var resource = load("res://assets/hold_wall_tutorial.dialogue")
var dialogue_line

#boolean triggers
var has_tutorial_played = false
var has_success_played = false

var has_tutorial_ended = false

# ending timer
var start_end_timer = false
var time_after_end = 0.6
var time_to_quit = 1.5
var end_timer = 0
var disable_end_timer = false

func _ready():
	hideDialogue()
	self.set_process_input(false)

func _process(delta):
	if has_tutorial_played or has_success_played:
		if Input.is_action_just_pressed('next'):
			if dialogue_line != null: dialogue_line = await resource.get_next_dialogue_line(dialogue_line.next_id)
			if dialogue_line != null: renderDialogue()
			else: 
				hideDialogue()
				has_tutorial_ended = true

func renderDialogue():
	showDialogue()
	
	character_name.set_text(dialogue_line.character)
	character_dialogue.set_text(dialogue_line.text)
	
	var mood = dialogue_line.get_tag_value('mood')
	match(mood):
		'mad': sprite_texture.texture = BLAIR_MAD
		'apologetic': sprite_texture.texture = LUCA_APOLOGETIC
		'sigh': sprite_texture.texture = BLAIR_SIGH
		'explaining': sprite_texture.texture = BLAIR_EXPLAINING
		'pointing up': sprite_texture.texture = BLAIR_UP
		'luca_neutral': sprite_texture.texture = LUCA_NEUTRAL
		'questioning': sprite_texture.texture = LUCA_QUESTIONING
		'agitated': sprite_texture.texture = BLAIR_AGITATED
		'blair_neutral': sprite_texture.texture = BLAIR_NEUTRAL
		'happy': sprite_texture.texture = LUCA_HAPPY

func hideDialogue():
	self.visible = false

func showDialogue():
	self.visible = true

func _on_dialogue_trigger_area_entered(area):
	if not has_tutorial_played:
		has_tutorial_played = true
		dialogue_line = await resource.get_next_dialogue_line("tutorial")
		showDialogue()
		renderDialogue()
		self.set_process_input(true)

func _on_dialogue_success_trigger_area_entered(area):
	if not has_success_played and has_tutorial_ended:
		has_success_played = true
		dialogue_line = await resource.get_next_dialogue_line("success")
		showDialogue()
		renderDialogue()
		self.set_process_input(true)

func can_play_end():
	return has_success_played and has_tutorial_played

func is_end_timer_done():
	return end_timer >= time_after_end

