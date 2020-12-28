extends KinematicBody2D

const UP = Vector2(0, -1)
const SLOPE_STOP = 40 # odpowiada za zatrzymanie na skosie

var velocity = Vector2()
var move_speed = 250
var gravity = 500
var jump_velocity = -350
var is_grounded

func _get_input():
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right")) #movement w lewo i w prawo
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2) #odpowiada za nadanie predkosci, ostatnia wartosc to przyspieszenie
	if move_direction != 0:
		$AnimatedSprite.scale.x = move_direction #kierunek animacji

func _input(event):
	if event.is_action_pressed("jump") && is_grounded: #skok
		velocity.y = jump_velocity
	if event.is_action_released("jump"):
		velocity.y = 8.33

func _physics_process(delta):
	_get_input()
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)  #predkosc postaci w grze
	velocity.y += gravity * delta  #odpowiada za zaprogramowanie grawitacji
	is_grounded = is_on_floor()
	

