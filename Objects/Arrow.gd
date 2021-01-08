extends RigidBody2D

onready var Globals = get_node("/root/Variables")
var speed = 400

func _on_Area2D_area_entered(area):
	sleeping = true
	$Area2D/CollisionShape2D2.set_disabled(true)
	$CollisionShape2D.set_disabled(true)
