extends KinematicBody2D

const UP = Vector2(0, -1)
const SLOPE_STOP = 40

var velocity = Vector2()
var move_speed = 250
var gravity = 500
var jump_velocity = -350
var is_grounded = is_on_floor() 

func _get_input():
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
	if move_direction != 0:
		$AnimatedSprite.scale.x = move_direction

func _input(event):
	if event.is_action_pressed("jump") && is_grounded:
		velocity.y = jump_velocity

func _physics_process(delta):
	_get_input()
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	velocity.y += gravity * delta
	

