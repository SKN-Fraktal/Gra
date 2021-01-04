extends Area2D

export (String, FILE, "*.tscn") var scene

func _on_Area2D_body_entered(body):
	if(body.name == "Player"):
		get_tree().change_scene(scene) 
#To strasznie slaby sposob na zmiane levelu, ale mialem juz na to kod
#Wiec po prostu go sam sobie ukradlem
