extends KinematicBody2D

const UP = Vector2(0, -1)
const SLOPE_STOP = 40

var velocity = Vector2()
var move_speed = 250
var gravity = 500
var jump_velocity = -200
var is_grounded
var health = 100
var lives = 3
var is_attack = false
var can_dash = true
const DASH_SPEED = 1000
onready var V= get_node("/root/Variables")

func _ready():
	new_game()
	connect("PlayerAttack", self, "_on_Player_Attack")

signal PlayerAttack

func _get_input():
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
	if move_direction != 0:
		$AnimatedSprite.scale.x = move_direction
	if Input.is_action_just_pressed("attack"):
		is_attack = true
	else:
		is_attack = false
	if Input.is_action_just_pressed("dash")&&((Input.is_action_pressed("move_left"))||(Input.is_action_pressed("move_right")))&&can_dash == true && is_grounded == true:
		dash()

func _input(event):
	if event.is_action_pressed("jump")&&is_grounded:
		velocity.y = jump_velocity
	if event.is_action_released("jump"):
		velocity.y = 8.33

func _physics_process(delta):
	_get_input()
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	velocity.y += gravity * delta
	is_grounded = is_on_floor()
	if velocity.x == 0:
		$AnimatedSprite.animation = "Idle"
	else:
		$AnimatedSprite.animation = "Move"
#atak postacina zasadzie nakladajacych sie areas, damage przyjmie tylko grupa 'hurtable'
	if is_attack:
		var objects = $AnimatedSprite/PlayerAttack.get_overlapping_areas()
		for object in objects:
			if object.is_in_group("hurtable"):
				var Enemy = object.get_parent()
				Enemy.take_damage()
				
	if move_speed > 250: #reset predkosci dla dasha
		move_speed -= 50


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
	if health <= 0:
		lives -= 1
	if lives == 0:
		fail()

#sygnal ataku bronia krotkodystansowa, calosc podpieta jest do sprite, tutaj jest prosto, zeby mob dostal obrazenia
#trzeba dodac do jego kodu odebranie sygnału i otrzymanie obrazen, specjalnie nie dodaje wartosci z gory
#tak zeby mozna bylo decydowac indywidualnie dla kazdego moba
func take_damage(): 
	health -= 50

func _on_player_attack(area):
	pass

#funkcja dasha i jej timer
func dash():
	move_speed = DASH_SPEED
	can_dash = false
	$DashCooldown.start()

func _on_DashCooldown_timeout():
	can_dash = true


