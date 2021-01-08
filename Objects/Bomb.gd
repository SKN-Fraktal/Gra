extends RigidBody2D

var move_speed = 200
var explosion = false

func _on_BombAnimationFinished():
	if $AnimatedSprite.animation == "Bomb_Fly":
		$AnimatedSprite.animation = "Bomb_Explode"
		var objects = $Area2D.get_overlapping_areas()
		for object in objects:
			if object.is_in_group("hurtable"):
				var Enemy = object.get_parent()
				Enemy.bomb_damage()
	if $AnimatedSprite.animation =="Bomb_Explode":
		queue_free()
		

	
