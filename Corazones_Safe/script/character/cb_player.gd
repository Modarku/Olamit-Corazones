extends CharacterBody2D

# VARIABLES
@onready var collision = $CollisionShape2D
@onready var animation = $AnimatedSprite2D
@onready var t_dashstate = $DashTimers/T_dashstate
@onready var t_dashcooldown = $DashTimers/T_dashcooldown
@onready var t_holdcooldown = $T_holdcooldown
@onready var rc_right = $RC_right
@onready var rc_left = $RC_left
@onready var tpb_staminabar = $TPB_staminabar
@onready var p_dash_cooldown = $Particles/DashCooldown/CPUParticles2D
@onready var p_dash_particles = $Particles/DashParticles/CPUParticles2D
@onready var scarf_end = $ScarfContainer/ScarfEnd

# const vars
const SPEED = 200.0
const JUMP_VELOCITY = -350.0
const FALL_FASTER_SPEED = 2.5
const MAX_FALL_SPEED = 1000.0
const DASH_SPEED = 400.0
const DASH_COST = 10.0
const MAX_STAMINA = 2.0
# movement vars
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# boolean vars
var is_touching_wall = false
var already_on_wall = false
var can_hold_wall = true
var is_dashing = false
var dash_cooldown = false
var already_jumped = false

# animation vars
var jump_playing = false

# stamina bar vars
var can_regen = false
var time_to_wait = 2.0
var stamina_timer = 0
var can_start_stamina_timer = true
var stamina = MAX_STAMINA

# improved jump mechanic
var time_to_jump = 0.5
var can_jump = true
var jump_timer = 0
var can_start_jump_timer = false

# particle vars
var flipped = false
var prev_flipped = false

#MAIN CODE
func _ready():
	tpb_staminabar.value = tpb_staminabar.max_value

func _process(delta):
	#stamina bar timer
	if can_regen == false and tpb_staminabar.value != 100 or tpb_staminabar.value == 0:
		can_start_stamina_timer = true
		if can_start_stamina_timer:
			stamina_timer += delta
			if stamina_timer >= time_to_wait:
				can_regen = true
				can_start_stamina_timer = false
				stamina_timer = 0
	
	if tpb_staminabar.value == 100:
		can_regen = false
		stamina = MAX_STAMINA
		tpb_staminabar.visible = false
	else: 
		tpb_staminabar.visible = true
	
	if can_regen == true:
		can_hold_wall = true
		stamina += delta
		tpb_staminabar.value = int(((stamina)/MAX_STAMINA)*100)
		can_start_stamina_timer = false
		stamina_timer = 0
	
	if already_on_wall:
		stamina -= delta
		tpb_staminabar.value = int((stamina/MAX_STAMINA)*100)
		can_regen = false
		stamina_timer = 0
	
	if tpb_staminabar.value == 0:
		has_held_wall = false
		can_hold_wall = false
		can_jump = false
		already_on_wall = false
	
	#jump timer
	if not is_on_floor():
		can_start_jump_timer = true
		if can_start_jump_timer:
			jump_timer += delta
			if jump_timer >= time_to_jump:
				can_jump = false
				can_start_jump_timer = false
				jump_timer = 0
	
	if is_on_floor():
		can_jump = true
		already_jumped = false

func _physics_process(delta):
	
	movement(delta)
	movementMechanics(delta)
	movementCheck()
	
	move_and_slide()


# MOVEMENT ANIMATIONS

func movement(delta):
	# add the gravity
	if not is_on_floor():
		if input_falling_faster:
			velocity.y += gravity * FALL_FASTER_SPEED * delta
		else:
			velocity.y += gravity * delta
		
	# handle jump
	if Input.is_action_just_pressed("jump") and not already_jumped and (can_jump or state_name == 'Holding Wall'):
		already_jumped = true
		velocity.y = JUMP_VELOCITY

	# get the input direction and handle the movement/deceleration
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# dash mechanics
	var facing = -1 if animation.flip_h else 1
	if is_dashing:
		velocity.y = 0
		velocity.x = facing * DASH_SPEED

func movementCheck():
	#checking wall raycasts
	if rc_left.is_colliding() or rc_right.is_colliding():
		is_touching_wall = true
	else:
		is_touching_wall = false
	
	#checks whether jump should be playing when in the air
	if velocity.y == 0:
		jump_playing = false
	
	#stops the particles once done dashing
	if not is_dashing:
		p_dash_particles.emitting = false
		
	#checks fall speed limit
	if velocity.y >= MAX_FALL_SPEED:
		velocity.y = MAX_FALL_SPEED
	
	#handle switching sides
	if state_name != 'Holding Wall':
		if velocity.x > 0:
			animation.flip_h = false
			flipped = false
			flipImageParticle()
		if velocity.x < 0:
			animation.flip_h = true
			flipped = true
			flipImageParticle()

func movementMechanics(delta):
	#apply impulse to make scarf affect wind
	scarf_end.apply_force((-velocity/12), velocity)
	
	#PlayerState to handle animation sprites
	state_name = getPlayerState()
	
	#state_switch-case
	match(state_name):
		'Idle':
			animation.play("idle_loop")
		'Moving':
			animation.play("run_loop")
		'Jumping':
			playJump()
		'Falling':
			animation.play("fall_loop")
		'Falling Faster':
			animation.play("fall_fast_loop")
		'Holding Wall':
			playHold()
		'Dashing':
			playDash()

func flipImageParticle():
	if flipped != prev_flipped:
		prev_flipped = flipped
		var img = p_dash_particles.texture.get_image()
		img.flip_x()
		p_dash_particles.texture = ImageTexture.create_from_image(img)

func playJump():
	if not jump_playing:
		animation.play("jump")
		jump_playing = true
	if already_on_wall:
		t_holdcooldown.start()
		already_on_wall = false

func playHold():
	already_jumped = false
	if t_holdcooldown.is_stopped():
		if tpb_staminabar.value != 0:
			velocity = Vector2.ZERO
			animation.play("hold")
			has_held_wall = true
			already_on_wall = true
		else:
			animation.play("fall_loop")

func playDash():
	if not is_dashing and not dash_cooldown:
		t_dashstate.start()
		t_dashcooldown.start()
		is_dashing = true
		dash_cooldown = true
		p_dash_particles.emitting = true
		animation.play("dash_loop")


# PLAYER STATE MACHINE

#Refer to spreadsheet
var state_table=[
	[0, 1, 0, 2, 0, 3, 0],
	[0, 1, 1, 2, 1, 3, 1],
	[2, 2, 2, 6, 5, 3, 0],
	[3, 3, 4, 6, 5, 3, 0],
	[3, 4, 4, 6, 5, 3, 0],
	[3, 5, 5, 2, 5, 5, 0],
	[0, 6, 6, 6, 5, 3, 0]
	]
var state = 0
var input = 0
var state_names = [
	'Idle', 'Moving', 'Jumping', 'Falling',
	'Falling Faster', 'Holding Wall', 'Dashing'
	]
var state_name = ''
var input_names = [
	'no input', 'move', 'fall faster', 'jump/dash',
	'hold wall', 'fall', 'land', 'failed'
	]#'failed' for checking in debugging
var input_name = ''
var prev_state = ''

#trigger once held inputs
var input_idling = false
var input_running = false
var input_falling = false
var input_falling_faster = false
var input_holding_wall = false

#trigger once only inputs
#certain inputs such as dashing, landing, and jumping only need to be triggered once as opposed to the other inputs
var has_jumped = false
var has_dashed = false
var has_landed = false
var has_fallen = false
var has_held_wall = false

#configures the player inputs
func getPlayerInput():
	input_running = true if Input.is_action_pressed("left") or Input.is_action_pressed("right") else false

	input_falling_faster = true if Input.is_action_pressed("fall") else false
	
	has_jumped = true if Input.is_action_just_pressed("jump") else false
	
	input_holding_wall = true if Input.is_action_pressed("hold") else false
	
	if velocity.y > 0:
		input_falling = true
		has_landed = false
	else: input_falling = false
	
	if has_jumped: has_held_wall = false
	
	if is_dashing: has_dashed = true

#returns the player state
func getPlayerState():
	getPlayerInput()
	prev_state = state_names[state]
	
	if is_dashing:
		input_name = 'jump/dash'
	elif (input_holding_wall or has_held_wall) and is_touching_wall and can_hold_wall:
		input_name = 'hold wall'
	elif can_jump and not has_landed:
		has_landed = true
		has_fallen = false
		input_name = 'land'
	elif has_jumped:
		input_name = 'jump/dash'
	elif input_falling_faster and has_fallen and not has_dashed:
		input_name = 'fall faster'
	elif input_falling:
		has_fallen = true
		has_dashed = false
		input_name = 'fall'
	elif input_running:
		input_name = 'move'
	else:
		input_name = 'no input'
	
	input = input_names.find(input_name)
	state = state_table[state][input]
	
	#print(input_names[input])
	#print(state_names[state])
	
	displayTransition()
	
	return state_names[state]

func getStateForLabel():
	return state_name

func displayTransition():
	if state_names[state] != prev_state:
		if prev_state == 'Falling Faster' or prev_state == 'Holding Wall':
			print(prev_state, '\thas transitioned to\t\t\t', state_names[state])
		else:
			print(prev_state, '\t\t\thas transitioned to\t\t\t', state_names[state])


# DASH TIMERS

func _on_t_dashstate_timeout():
	is_dashing = false

func _on_t_dashcooldown_timeout():
	dash_cooldown = false
	p_dash_cooldown.emitting = true

func _on_t_holdcooldown_timeout():
	pass
