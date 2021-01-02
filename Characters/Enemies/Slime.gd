extends Enemies

const UP = Vector2.UP
var is_alerted = false # Kiedy przeciwnik widzi gracza
var jump_timer_timeout = false # Kiedy mob jest zaalarmowany i timer pozwala mu zrobic nastepny podskok
var motion = Vector2.ZERO
export var jump_height = -100
export var speed = 25
export var gravity = 4
export var direction = Vector2.ZERO # Mozna z poziomu edytora leveli wybrac w ktora strone ma isc mobek

func _ready() -> void:
	randomize() # Losowy seed
	
	if direction.x == 0: # Jezeli kierunek wybrano w edytorze, nie losujemy kierunku
		direction.x = randi() % 2 # Losowy kierunek ruchu na starcie
		if (direction.x == 0):
			direction.x = -1
	
func _on_DetectionArea_body_entered(body: Node) -> void: # Detekcja playera
	if is_alerted == false: 
		is_alerted = true # Agresywniejszy movement po spotkaniu gracza
		$jump_timer.start()
		speed *= 2
		$AnimatedSprite.speed_scale = 2

func _physics_process(delta: float) -> void:
	if is_on_floor(): #kontakt z podloga
		if is_on_wall(): # Zmiana kierunku po zderzeniu ze sciana
			direction.x = -direction.x
			motion.x = -motion.x
			
		motion.y = 0 # y = 0 przy kontakcie z podloga
		motion.x = direction.x * speed
		
		if is_alerted: # Miejsce na dodatkowe zachowania mobkow przy alercie
			if jump_timer_timeout == true: # Skakanie przy alercie
				motion.y += jump_height
				jump_timer_timeout = false
				
	elif !is_on_floor():
		motion.y += gravity
		
		if is_on_ceiling():
			motion.y = 0
		
	move_and_slide(motion, UP)

func _on_Timer_timeout() -> void: # jump timer
	jump_timer_timeout = true
