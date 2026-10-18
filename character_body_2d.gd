extends CharacterBody2D

var speed = 125

var max_stamina = 100.0
var stamina = 100.0
var stamina_drain = 50
var stamina_regen = 25
var is_exhausted = false

@onready var weapon = $Weapon

var max_health = 100.0
var health = 100.0
var stamina_bar
var health_bar

var is_dead = false
var death_screen
var win_screen

var attack_cooldown = 0.5
var attack_timer = 0.0
var aim_direction = Vector2.RIGHT
var attack_animation_timer = 0.0
var attack_animation_duration = 0.15

var attack_damage = 10
var weapon_reach = 85.0 
var swing_arc = 70.0    

var is_attacking = false
var enemies_hit = []

var god_mode = false

func _ready():
	add_to_group("player")
	health_bar = get_node_or_null("../UI/PlayerStats/Health")
	stamina_bar = get_node_or_null("../UI/PlayerStats/Stamina")
	death_screen = get_node_or_null("../UI/DeathScreen")
	win_screen = get_node_or_null("../UI/WinScreen")
	
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
		
	
	var god_btn = get_node_or_null("../UI/DebugPanel/GodModeToggle")
	if god_btn:
		if god_btn is CheckBox:
			god_btn.toggled.connect(_on_god_mode_toggled)
		else:
			god_btn.pressed.connect(_on_god_mode_button_pressed)
			
	var kill_btn = get_node_or_null("../UI/DebugPanel/KillSelfButton")
	if kill_btn:
		kill_btn.pressed.connect(die)
		
	
	var death_restart_btn = get_tree().current_scene.find_child("RestartButton", true, false)
	if death_restart_btn:
		death_restart_btn.pressed.connect(GameManager._on_restart_button_pressed)
		print("🔌 Connected Standard Restart Button to GameManager!")

	var wave10_replay_btn = get_tree().current_scene.find_child("PlayAgainButton", true, false)
	if wave10_replay_btn:
		wave10_replay_btn.pressed.connect(GameManager._on_play_again_button_pressed)
		print("🔌 Connected Wave 10 Play Again Button to GameManager!")

	$Weapon/AttackArea.monitoring = false

func _physics_process(delta):
	attack_timer -= delta
	
	aim_direction = global_position.direction_to(get_global_mouse_position()).normalized()
	weapon.position = aim_direction * 20.0

	if attack_animation_timer > 0:
		attack_animation_timer -= delta
		var progress = 1.0 - (attack_animation_timer / attack_animation_duration)
		var swing_angle = lerp(-0.8, 0.3, progress)
		weapon.rotation = aim_direction.angle() + swing_angle
	else:
		weapon.rotation = aim_direction.angle()
		is_attacking = false
		
	var current_speed = speed
	if stamina <= 0:
		is_exhausted = true
		if stamina_bar: stamina_bar.self_modulate = Color.RED
	elif stamina >= 50.0:
		is_exhausted = false
		if stamina_bar: stamina_bar.self_modulate = Color.GREEN
			
	if Input.is_key_pressed(KEY_SHIFT) and velocity != Vector2.ZERO and stamina > 0 and not is_exhausted:
		current_speed = speed * 2
		stamina -= stamina_drain * delta
	else:
		stamina += stamina_regen * delta
			
	stamina = clamp(stamina, 0.0, max_stamina)
	
	velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"): velocity.x = current_speed
	elif Input.is_action_pressed("ui_left"): velocity.x = -current_speed
	if Input.is_action_pressed("ui_down"): velocity.y = current_speed
	elif Input.is_action_pressed("ui_up"): velocity.y = -current_speed
	
	if Input.is_action_just_pressed("Attack") and attack_timer <= 0 and not is_attacking:
		attack_animation_timer = attack_animation_duration
		attack_timer = attack_cooldown
		is_attacking = true
		execute_physical_slash() 
	
	move_and_slide()
	
	if stamina_bar: stamina_bar.value = stamina
	if health_bar: health_bar.value = health

func execute_physical_slash():
	enemies_hit.clear()
	$Weapon/AttackArea.monitoring = true
	await get_tree().physics_frame
	$Weapon/AttackArea.monitoring = false

func _on_god_mode_toggled(is_toggled: bool):
	god_mode = is_toggled
	print("God Mode set to: ", god_mode)

func _on_god_mode_button_pressed():
	god_mode = not god_mode
	print("God Mode toggled via button to: ", god_mode)

func take_damage(amount):
	if god_mode:
		return 
		
	health -= amount
	health = clamp(health, 0.0, max_health)
	if health_bar: health_bar.value = health

	if health <= 0:
		die()

func die():
	if is_dead: return 
	is_dead = true
	visible = false
	set_physics_process(false)
	
	
	GameManager.trigger_player_death_ui()


func _on_attack_area_area_entered(area: Area2D) -> void:
	var target = area if area.is_in_group("enemies") else area.get_parent()
	if target.is_in_group("enemies") and not target in enemies_hit:
		enemies_hit.append(target)
		if target.has_method("take_damage"):
			target.take_damage(attack_damage)

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and not body in enemies_hit:
		enemies_hit.append(body)
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
