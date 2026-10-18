extends CharacterBody2D

var speed = 85.0
var player = null

var max_health = 50.0
var health = 50.0

var attack_damage = 2 
var attack_cooldown = 1.0
var attack_timer = 0.0


@onready var health_bar = $EnemyHealth

func _ready():
	add_to_group("enemies") 
	
	
	if health_bar:
		health_bar.max_value = 100.0
		health_bar.value = 100.0
	
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		player = get_parent().get_node_or_null("Player") 

func _physics_process(delta):
	attack_timer -= delta
	
	if player == null:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0: player = players[0]

	if player != null and not player.is_dead:
		var direction = global_position.direction_to(player.global_position)
		var distance = global_position.distance_to(player.global_position)
		
		var separation_vector = Vector2.ZERO
		var active_clones = get_tree().get_nodes_in_group("enemies")
		for clone in active_clones:
			if clone != self and is_instance_valid(clone):
				var dist_to_clone = global_position.distance_to(clone.global_position)
				if dist_to_clone < 40.0 and dist_to_clone > 0:
					separation_vector += clone.global_position.direction_to(global_position) * (40.0 / dist_to_clone)

		if distance <= 55.0:
			velocity = separation_vector * 50.0 
			if attack_timer <= 0:
				player.take_damage(attack_damage)
				attack_timer = attack_cooldown
		else:
			velocity = (direction * speed) + (separation_vector * 35.0)
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()


func take_damage(amount):
	health -= amount
	health = clamp(health, 0.0, max_health)
	print("Clone damaged! Current HP: ", health)
	
	
	if health_bar:
		var health_percentage = (health / max_health) * 100.0
		health_bar.value = health_percentage
	
	if health <= 0:
		if GameManager.has_method("enemy_killed"):
			GameManager.enemy_killed()
		queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player.take_damage(attack_damage)
		attack_timer = attack_cooldown
