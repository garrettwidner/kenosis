extends KinematicBody2D

const GRAVITY = 12
const SINGLE_JUMP_VELOCITY = 250
const UP = Vector2(0, -1)
const SPEED = 100
const MAX_FALL_SPEED = 300

const CENTERED_LEEWAY = 0.1

onready var front_check = get_node("FrontCheck")
onready var anim_player = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")

var is_facing_right = true
var velocity = Vector2(0, 0)
var is_grounded = true
var is_moving_right = false
var is_moving_left = false

func _ready():
	add_to_group(game.GROUP_PLAYER)
	center_character()
	
func _physics_process(delta):
	velocity.y += GRAVITY
	velocity = set_horizontal_speed(velocity)
	
	change_front_check_position()
	
	velocity = move_and_slide(velocity, UP)
	
	if(Input.is_key_pressed(KEY_Y)):
		center_character()
	if(Input.is_key_pressed(KEY_T)):
		is_centered_x()
	
func set_horizontal_speed(velocity):
	if Input.is_action_pressed("move_right") && !is_moving_left:
		velocity.x = SPEED
		is_moving_right = true
		is_moving_left = false
	elif Input.is_action_pressed("move_left") && !is_moving_right:
		velocity.x = -SPEED
		is_moving_left = true
		is_moving_right = false
	else:
		#TODO: Need to move to find_next_centered_x 
		if is_moving_right && !is_centered_x():
			velocity.x = SPEED
		elif is_moving_left && !is_centered_x():
			velocity.x = -SPEED
		else:
			velocity.x = 0
			is_moving_right = false
			is_moving_left = false
		
	
		
	#if !Input.is_action_pressed("move_right"):
	
		
	return velocity
	
func change_front_check_position():
	if Input.is_action_pressed("move_right"):
		if sign(front_check.position.x) == -1:
			front_check.position.x *= -1
	elif Input.is_action_pressed("move_left"):
		if sign(front_check.position.x) == 1:
			front_check.position.x *= -1

func find_next_centered_x():
	var current_centered = get_centered_position(global_position)
	
	if(is_moving_left):
		return Vector2(current_centered.x - 16, current_centered.y)
	elif(is_moving_right):
		return Vector2(current_centered.x - 16, current_centered.y)
	else:
		return current_centered
	
func get_centered_position(current_vector):
	var remainder_x = fmod(current_vector.x, 16)
	var remainder_y = fmod(current_vector.y, 16)
	return Vector2(current_vector.x - remainder_x + 8, current_vector.y - remainder_y + 8)
			
func center_character():
	position = get_centered_position(global_position)
	
func is_centered_x():
	if(abs(get_centered_position(global_position).x - global_position.x) < CENTERED_LEEWAY):
		return true
	else:
		return false
	
	