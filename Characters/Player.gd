extends KinematicBody2D

const UP = Vector2(0, -1)
const SLOPE_STOP = 40 # odpowiada za zatrzymanie na skosie

var velocity = Vector2()
var move_speed = 250
var gravity = 500
var jump_velocity = -350
var endofjump = 0
var is_grounded
var health = 100
var lives = 3

func _ready():
	new_game()

func _get_input():
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right")) #movement w lewo i w prawo
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2) #odpowiada za nadanie predkosci, ostatnia wartosc to przyspieszenie
	if move_direction != 0:
		$AnimatedSprite.scale.x = move_direction #kierunek animacji

func _input(event):
	if event.is_action_pressed("jump") && is_grounded: #skok
		endofjump = 0
		velocity.y = jump_velocity
	#odpowiada za wysokosc skoku
	if event.is_action_released("jump")&& !endofjump:
		if velocity.y < 0:
			velocity.y = 8.33
		endofjump = 1

func _physics_process(delta):
	_get_input()
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)  #predkosc postaci w grze
	velocity.y += gravity * delta  #odpowiada za zaprogramowanie grawitacji
	is_grounded = is_on_floor()
	
	
#nie wiem czy to sie tak robi, i jaki byl sygnal by to był ale domyslam sie ze taki, narazie to
#poczatek, potem jak juz beda sygnaly to bede nad nia pracowal
func _on_CollisionDetector_body_entered(body):
	health -= 10

#tutaj jest funkcja ktora bedzie wyswietlala ekran porażki, grała jakis tam deathsound etc.
func fail():
	pass

#odpowiada za nowa gre
func new_game():
	pass

#ta funkcja odpowiada za sprawdzenie czy postac zyje
func game_lasts():
	if health <= 100:
		lives -= 1
	if lives == 0:
		fail()
	

