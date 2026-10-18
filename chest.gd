extends Area2D

var player = null

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null

func _process(_delta):
	if player != null and Input.is_action_just_pressed("interact"):
		player.chest_opened = true
		
