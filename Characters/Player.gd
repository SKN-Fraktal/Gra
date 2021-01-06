extends KinematicBody2D

const UP = Vector2(0, -1)
const SLOPE_STOP = 40
const DASH_SPEED = 1000

onready var V= get_node("/root/Variables")

var velocity = Vector2()
var move_speed = 200
var gravity = 1200
var jump_velocity = -300
var is_grounded
var health = 100
var lives = 3
var movement_action 
var is_attack = false
var can_dash = true
var is_jumping = false
var is_blocking = false
var MegaJump = true
var stomp = false
var can_stomp = true

#Komentarz ogolny co sie dzieje i co potrzeba jeszcze zrobic:
#Obecnie pracuje nad nastepnymi funkcjami i ulepszeniami
#W tym momencie bugi w kodzie na ktore nie mam pomysłu to:
#-Brak wyswietlania animacji ataku gdy postac jest w powietrzu
#-gdy tzyma sie caly czas klawisz W i postac juz opadnie na ziemie, dalej wyswietla sie animacja skoku
#-nalezy poprawic jakosc tekstur nowych animiacji

#ogolnie od prob naprawienia tego, prawdopodobnie w kodzie powstało lekkie spaghetti
#czesc funkcji moze byc zbyteczna, ale w sumie nie szkodza one, sprobuje potem w miarre mozliwosci cos 
#pousuwac ale obecnie nie mam juz sily na prace nad animacjami


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


func _get_input():
	var move_direction = -int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, 0.2)
	if move_direction != 0:
		$AnimatedSprite.scale.x = move_direction
	if Input.is_action_just_pressed("attack"):
		$AnimatedSprite.animation = "Attack"
		is_attack = true
		$AnimatedSprite.offset.x = 8
	if Input.is_action_just_pressed("dash")&&((Input.is_action_pressed("move_left"))||(Input.is_action_pressed("move_right")))&&can_dash == true && is_grounded == true:
		dash()
	#stomp
	if Input.is_action_just_pressed("stomp"):
		_Stomp()
	
func _input(event):
	if event.is_action_pressed("jump")&&is_grounded:
		velocity.y = jump_velocity
		is_jumping = true
	if event.is_action_released("jump"):
		velocity.y = 8.33
		is_jumping = false
	if event.is_action_pressed("Block"):
		is_blocking = true
		$AnimatedSprite.offset.x = 0
	if event.is_action_released("Block"):
		is_blocking = false
	if event.is_action_pressed("jump_boost")&&MegaJump == true:
		_MegaJump()
		is_jumping = true
	if event.is_action_released("jump_boost"):
		is_jumping = false


func _physics_process(delta):
	_get_input()
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	velocity.y += gravity * delta
	is_grounded = is_on_floor()
	#sekwencja instrukcji poniżej odpowiada za animacje
	if !is_attack:
		if velocity.x == 0:
			$AnimatedSprite.animation = "Idle"
			movement_action = "Idle"
		else:
			$AnimatedSprite.animation = "Move"
			$AnimatedSprite.offset.x = 0
			movement_action = "Move"
	if is_jumping&&is_grounded:#ta instrukcja narazie zapycha ale moze byc calkiem spoko
		$AnimatedSprite.animation = "Nojump"
	if is_jumping:
		$AnimatedSprite.animation = "Jump"
		$AnimatedSprite.offset.x = 0
	elif is_jumping&&is_attack:#ta odpowiada za atak podczas skoku, dzieki niej calosc dziala ale mimo wszystko jest blad animacji
		_on_AnimatedSprite_frame_changed()
		$AnimatedSprite.animation = "Attack"
		$AnimatedSprite.offset.x = 8
	elif !is_jumping && velocity.y >21:#ta odpowiada za atak podczas spadku, dzieki niej calosc dziala ale mimo wszystko jest blad animacji
		_on_AnimatedSprite_frame_changed()
		$AnimatedSprite.animation = "Fall"
		$AnimatedSprite.offset.x = 0
		movement_action = "Fall"
		if is_attack:
			$AnimatedSprite.animation = "Attack"
			$AnimatedSprite.offset.x = 8
			_on_AnimatedSprite_animation_finished()
	if is_blocking&&(!is_attack):
		$AnimatedSprite.animation = "Block"
#atak postaci na zasadzie nakladajacych sie areas, damage przyjmie tylko grupa 'hurtable'
	if is_attack:
		var objects = $AnimatedSprite/PlayerAttack.get_overlapping_areas()
		for object in objects:
			if object.is_in_group("hurtable"):
				var Enemy = object.get_parent()
				Enemy.take_damage()
	
	if move_speed > 250: #reset predkosci dla dasha
		move_speed -= 50
	
	#stomp
	if stomp && is_grounded:
		print("test")
		var objects = $AnimatedSprite/StompArea.get_overlapping_areas()
		for object in objects:
			if object.is_in_group("hurtable"):
				var Enemy = object.get_parent()
				Enemy.StompDamage()
		

#sygnal konca odtwarzania animacji ataku, poprawa offsetu
func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "Attack":
		is_attack = false
		$AnimatedSprite.offset.x = 0
		#tutaj tez prawdopodobnie jest spaghetii chociaz zapobiega to nieprawidlowym animacja
		if is_jumping:
			$AnimatedSprite.animation = "Jump"
		elif movement_action == "Idle":
			$AnimatedSprite.animation = "Idle"
		elif movement_action == "Move":
				$AnimatedSprite.animation = "Move"
		elif !is_jumping&&velocity.y > 17:
			$AnimatedSprite.animation = "Fall"


#tutaj prawdopodobnie pojawia sie spaghetii i raczej da sie to zrobic lepiej, jesli w ogole jest to potrzebne
func _on_AnimatedSprite_frame_changed():
	if $AnimatedSprite.animation == "Jump" || $AnimatedSprite.animation == "Fall":
		if is_attack:
			$AnimatedSprite.animation = "Attack"
			is_attack = false
			$AnimatedSprite.offset.x = 0
			
			
#nie wiem czy to sie tak robi, i jaki byl sygnal by to był ale domyslam sie ze taki, narazie to
#poczatek, potem jak juz beda sygnaly to bede nad nia pracowal
func _on_CollisionDetector_body_entered(body):
	_Taking_Damage()

func _Taking_Damage():
	pass
#ataki


#sygnal ataku bronia krotkodystansowa, calosc podpieta jest do sprite, tutaj jest prosto, zeby mob dostal obrazenia
#trzeba dodac do jego kodu odebranie sygnału i otrzymanie obrazen, specjalnie nie dodaje wartosci z gory
#tak zeby mozna bylo decydowac indywidualnie dla kazdego moba
func take_damage(): 
	health -= 50

func _on_player_attack(area):
	pass

#ponizej beda funkcje skilli

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

func _on_DashCooldown_timeout():
	can_dash = true

func _Stomp():
	stomp = true
	$StompCooldown.start()
	$StompingTime.start()
	

func StompCooldown():
	can_stomp = false

func _on_StompArea_area_entered(area):
	pass

func _on_StompingTime():
	stomp = false
