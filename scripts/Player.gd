extends KinematicBody2D

const GRAVITY = 12
const SINGLE_JUMP_VELOCITY = 250
const UP = Vector2(0, -1)
const SPEED = 50
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
var has_endpoint = false
var endpoint = Vector2(0,0)

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
		if (is_moving_right || is_moving_left) && !has_endpoint:
			set_endpoint(find_next_centered_x())
			print("Set endpoint to " + str(endpoint))
		elif has_endpoint && was_endpoint_passed():
			velocity.x = 0
			is_moving_right = false
			is_moving_left = false
			position = endpoint
			remove_endpoint()
			
		#TODO: Need to move to find_next_centered_x 
		#elif is_moving_right && !is_centered_x():
			#velocity.x = SPEED
		#elif is_moving_left && !is_centered_x():
			#velocity.x = -SPEED
		#else:
			#print("Velocity set to 0")
			#velocity.x = 0
			#is_moving_right = false
			#is_moving_left = false
		
	#if !Input.is_action_pressed("move_right"):
		
	return velocity
	
func change_front_check_position():
	if Input.is_action_pressed("move_right"):
		if sign(front_check.position.x) == -1:
			front_check.position.x *= -1
	elif Input.is_action_pressed("move_left"):
		if sign(front_check.position.x) == 1:
			front_check.position.x *= -1

func set_endpoint(new_endpoint):
	print("New endpoint: " + str(new_endpoint) + " current pos: " + str(position))
	endpoint = new_endpoint
	has_endpoint = true
	
func remove_endpoint():
	endpoint = Vector2(0,0)
	has_endpoint = false

func was_endpoint_passed():
	if(!has_endpoint):
		return false
	elif(is_moving_left && global_position.x < endpoint.x):
		return true
	elif(is_moving_right && global_position.x > endpoint.x):
		return true
	else:
		return false

func find_next_centered_x():
	var current_centered = get_centered_position_x(global_position)
	
	if(is_moving_left):
		return Vector2(current_centered.x - 16, current_centered.y)
	elif(is_moving_right):
		return Vector2(current_centered.x + 16, current_centered.y)
	else:
		return current_centered
	
func get_centered_position_x(current_vector):
	var remainder_x = fmod(current_vector.x, 16)
	return Vector2(current_vector.x - remainder_x + 8, current_vector.y)
			
func center_character():
	position = get_centered_position_x(global_position)
	
func is_centered_x():
	if(abs(get_centered_position_x(global_position).x - global_position.x) < CENTERED_LEEWAY):
		return true
	else:
		return false
	
	