extends Area2D

export var message = ""


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		get_node("Text").text = message #Ustawia wiadomosc na modana w Inspektorze


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		get_node("Text").text = "" #To czysci wiadomosc
