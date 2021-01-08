extends KinematicBody2D

const UP = Vector2(0, -1)
const SLOPE_STOP = 40
const DASH_SPEED = 1000

onready var V= get_node("/root/Variables")
var arrow = preload("res://Objects/Arrow.tscn")
var bomb = preload("res://Objects/Bomb.tscn")

#zmienne dla właściowsci postaci
var velocity = Vector2()
var move_speed = 200
var gravity = 1200
var jump_velocity = -300
var is_grounded
var health = 100
var lives = 3
var movement_action 
var mouse_position

#eksportowane zmienne potrzebe do działana knockbacku
var move_direction
var facing_direction = 0

#Komentarz ogolny co sie dzieje i co potrzeba jeszcze zrobic:
#Obecnie pracuje nad nastepnymi funkcjami i ulepszeniami
#W tym momencie bugi w kodzie na ktore nie mam pomysłu to:
#-gdy tzyma sie caly czas klawisz W i postac juz opadnie na ziemie, dalej wyswietla sie animacja skoku
#-nalezy poprawic jakosc tekstur nowych animiacji

func _ready():
	new_game()

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

#reset offsetu potrzeby do poprawnego działania animacji
func _offset_reset():
	$AnimatedSprite.offset.x = 0
	
func _get_input():
	#poruszanie się cz1, movement prawo lewo i skalowanie postaci
	move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
	if move_direction != 0:
		$AnimatedSprite.scale.x = move_direction
		
#inputy dla skilli
	if Input.is_action_just_pressed("dash")&&((Input.is_action_pressed("move_left"))||(Input.is_action_pressed("move_right")))&&can_dash == true && is_grounded == true:
		dash()
	#stomp
	if Input.is_action_just_pressed("stomp")&&can_stomp:
		_Stomp()
		
#mechanika walki, wybor broni:
	if Input.is_action_just_pressed("weapon_sword"):
		weapon = "sword"
	if Input.is_action_just_pressed("weapon_bow"):
		weapon = "bow"
	if Input.is_action_just_pressed("weapon_bomb"):
		weapon = "bomb"
		
	#input ataku i ograniczenie czestotliwosci
	if Input.is_action_just_pressed("attack")&&weapon == "sword"&&can_attack:
		is_attack = true
		$Attack_Time.start()
	
	#tutaj mamy strzał z łuku, sama strzała jest jeszcze troche mocno zabugowana,
	if Input.is_action_just_pressed("attack")&&weapon == "bow"&& arrow_amount > 0 && can_shot:
		var arrow_instance = arrow.instance()
		mouse_position = get_global_mouse_position()
		arrow_instance.rotation = get_angle_to(mouse_position)
		arrow_instance.linear_velocity = get_global_position().direction_to(mouse_position)* arrow_instance.speed
		arrow_instance.position = get_global_position()
		get_tree().get_root().add_child(arrow_instance)
		arrow_amount -= 1
		is_shoting = true
		$Shot_Time.start()
		if arrow_instance.linear_velocity.x == 0 && arrow_instance.linear_velocity.y == 0:
			arrow_instance.set_sleeping()
	
	#poniższy blok ifa to wywołanie rzutu bomba, sprawa calkiem prosta, jesli chcecie edytowac np dlugosc rzutu bomby to 
	#trzeba edytowac predosc w skrypcie i grawitacje, dodatkowo mozna edytowac jeszcze angular_v czyli obrot w powietrzu i
	#i same bomby maja nadanego losowego bounca
	if Input.is_action_just_pressed("attack") && weapon == "bomb":
		var bomb_instance = bomb.instance()
		mouse_position = get_global_mouse_position()
		bomb_instance.rotation = get_angle_to(mouse_position)
		bomb_instance.linear_velocity = get_global_position().direction_to(mouse_position)*bomb_instance.move_speed 
		bomb_instance.position = get_global_position()
		get_tree().get_root().add_child(bomb_instance)
		bomb_instance.set_bounce(rand_range(0, 1))
		
	
	
	
func _input(event):
#movement cz2. mechanika skoków i mega jumpu
	if event.is_action_pressed("jump")&&is_grounded:
		velocity.y = jump_velocity
		is_jumping = true
	if event.is_action_released("jump"):
		velocity.y = 8.33
		is_jumping = false

	if event.is_action_pressed("jump_boost")&&MegaJump == true:
		_MegaJump()
		is_jumping = true
	if event.is_action_released("jump_boost"):
		is_jumping = false
		
#WYJATEK, AKCJA Z WALKI TUTAJ
	if event.is_action_pressed("Block")&&can_block:
		is_blocking = true
	if event.is_action_released("Block"):
		is_blocking = false


func _physics_process(delta):
	#poruszanie sie i fizyczka, oraz zmienne okreslajace kierunek patrzenia
	_get_input()
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	velocity.y += gravity * delta
	is_grounded = is_on_floor()
	facing_direction = $AnimatedSprite.scale.x
	mouse_position = get_angle_to(get_global_mouse_position())
	#poniżej funkcjie poruszania, ataku i skilli
	_Movement_Actions()
	_Attack()
	_Shot()
	_Dash_Reset()
	Stomp()

#nie wiem czy to sie tak robi, i jaki byl sygnal by to był ale domyslam sie ze taki, narazie to
#poczatek, potem jak juz beda sygnaly to bede nad nia pracowal
func _on_CollisionDetector_body_entered(body):
	_Taking_Damage()

func _Taking_Damage():
	pass

func _on_player_attack(area):
	pass

#ponizej beda funkcje skilli
#zmienne potrzebne do tych funkcji
var can_dash = true
var is_jumping = false
var is_blocking = false
var MegaJump = true
var stomp = false
var can_stomp = true

#mega jump
func _MegaJump():
	velocity.y = jump_velocity - 200
	MegaJump = false
	$MegaJumpCooldown.start()
func _MegaJumpCooldown():
	MegaJump = true

#funkcja dasha i jej timer
func dash():
	move_speed = DASH_SPEED
	can_dash = false
	$DashCooldown.start()
func _Dash_Reset():
	if move_speed > 250: #reset predkosci dla dasha
		move_speed -= 50
func _on_DashCooldown_timeout():
	can_dash = true

func Stomp():
	if stomp && is_grounded && can_stomp:
		StompCooldown()
		var objects = $AnimatedSprite/StompArea.get_overlapping_areas()
		for object in objects:
			if object.is_in_group("hurtable"):
				var Enemy = object.get_parent()
				Enemy.StompDamage()
func _Stomp():
	stomp = true
	$StompCooldown.start()
func StompCooldown():
	can_stomp = false
func _on_StompArea_area_entered(area):
	pass
func _on_StompCooldown():
	can_stomp = true
	

#mechaniki walki

#zmienne potrzebne do działania mechanik walk
var weapon
var is_attack = false
var is_shoting = false
var arrow_speed = 2000
var arrow_amount = 5
var can_shot = true
var can_attack = true
var can_block = true

func _Shot():
	if is_shoting:
		Shot()
func Shot():
	if mouse_position < 1.5 && mouse_position > -1.5:
		$AnimatedSprite.scale.x = 1
	else:
		$AnimatedSprite.scale.x = -1
	$AnimatedSprite.offset.x = 8
	$AnimatedSprite.animation = "Bow_Shot"
func _Shot_Time():
	is_shoting = false
	can_shot = false
	$Shot_Time/ShotCooldown.start()
func _on_ShotCooldown():
	can_shot = true

#Funkje ataku mieczem, pomocnicza funkcja która blokuje bugowanie animacji i cooldown ataku wynoszacy 0.1s
func _Attack():
	if is_attack:
		melee_attack()
	else:
		_offset_reset()
func melee_attack():
		$AnimatedSprite.offset.x = 8
		$AnimatedSprite.animation = "Attack"
		var objects = $AnimatedSprite/PlayerAttack.get_overlapping_areas()
		for object in objects:
			if object.is_in_group("hurtable"):
				var Enemy = object.get_parent()
				Enemy.take_damage()
func _on_Attack_Time():
	is_attack = false
	can_attack = false
	$Attack_Time/AttackCooldown.start()
func _on_AttackCooldown():
	can_attack = true

func _Movement_Actions():
#sekwencja instrukcji poniżej odpowiada za animacje
	if !is_attack && !is_shoting:
		if velocity.x == 0 && weapon == "sword":
			$AnimatedSprite.animation = "Idle"
		elif velocity.x != 0 && weapon == "sword" :
			$AnimatedSprite.animation = "Move"
		elif velocity.x == 0 && weapon == "bow":
			$AnimatedSprite.animation = "Bow_Idle"
		elif velocity.x != 0 && weapon == "bow":
			$AnimatedSprite.animation = "Bow_Move"
	
	if is_jumping&& weapon =="sword"&& is_attack:
		melee_attack()
	elif is_jumping  && weapon == "sword":
		$AnimatedSprite.animation = "Jump"
	
	#spadek z mieczem i atak
	if !is_jumping&& weapon =="sword"&& is_attack:
		melee_attack()
	elif !is_jumping && velocity.y >21  && weapon == "sword":#ta odpowiada za atak podczas spadku, dzieki niej calosc dziala ale mimo wszystko jest blad animacji
		$AnimatedSprite.animation = "Fall"
		
	#skok z łukiem
	if is_jumping  && weapon == "bow":
		$AnimatedSprite.animation = "Bow_Jump"
	
	#spadek z łukiem
	elif !is_jumping && velocity.y >21  && weapon == "bow":#ta odpowiada za atak podczas spadku, dzieki niej calosc dziala ale mimo wszystko jest blad animacji
		$AnimatedSprite.animation = "Bow_Fall"
		
	if is_blocking&&(!is_attack):
		$AnimatedSprite.animation = "Block"
		
func _is_blocking():
	if is_blocking:
		var objects = $CollisionShape2D.get_overlapping_areas()
		for object in objects:
			if object.is_in_group("hurtable"):
				var Enemy = object.get_parent()
				Enemy.knockback()
