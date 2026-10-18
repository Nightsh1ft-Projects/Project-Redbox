extends Node2D

@export var enemy_scene : PackedScene

@onready var wave_timer = $WaveTimer
@onready var spawn_timer = $SpawnTimer
@onready var player = $Player


var current_wave = 1
var max_enemies_on_screen = 4


var wave_label: Label = null
var timer_label: Label = null

func _ready():
	
	GameManager.reset_game_data()
	
	print("Game started! Wave 1 begins.")
	
	var root_node = get_tree().current_scene
	wave_label = root_node.find_child("WaveDisplay", true, false) as Label
	timer_label = root_node.find_child("TimerDisplay", true, false) as Label
	
	update_wave_limits()
	wave_timer.start()
	spawn_timer.start()


func update_wave_limits():
	if current_wave <= 2:
		max_enemies_on_screen = 4
	elif current_wave <= 5:
		max_enemies_on_screen = 5
	elif current_wave <= 9:
		max_enemies_on_screen = 6
	elif current_wave >= 10:
		max_enemies_on_screen = 5
	
	
	GameManager.current_wave = current_wave
	print("Wave ", current_wave, " started! Maximum cap allowed: ", max_enemies_on_screen)

func _process(_delta):
	
	if wave_label:
		if current_wave >= 10:
			wave_label.text = "WAVE: 10 (ENDLESS)"
		else:
			wave_label.text = "WAVE: " + str(current_wave)
			
	if timer_label:
		if current_wave >= 10:
			timer_label.text = "SURVIVE!"
		else:
			timer_label.text = str(ceil(wave_timer.time_left)) + "s"

	if player == null or player.is_dead:
		spawn_timer.stop()

func _on_spawn_timer_timeout():
	if player == null or player.is_dead:
		spawn_timer.stop()
		return
	
	
	var current_enemy_count = get_tree().get_nodes_in_group("enemies").size()
	if current_enemy_count >= max_enemies_on_screen:
		return
		
	var timer_left = wave_timer.time_left
	
	
	if current_wave >= 10:
		spawn_single_enemy()
	elif timer_left > 45:
		if randf() > 0.33: 
			spawn_single_enemy()
	elif timer_left > 20:
		spawn_single_enemy()
	else:
		
		for i in range(4):
			if get_tree().get_nodes_in_group("enemies").size() < max_enemies_on_screen:
				spawn_single_enemy()

func spawn_single_enemy():
	if not enemy_scene: return
	
	var new_enemy = enemy_scene.instantiate()
	new_enemy.player = player
	

	var random_x = randf_range(0, 1152)
	var random_y = randf_range(0, 648)
	new_enemy.global_position = Vector2(random_x, random_y)
	
	add_child(new_enemy)

func _on_wave_timer_timeout():
	
	if current_wave >= 10:
		print("INFINITE SURVIVAL LOOP: Restarting wave timers.")
		wave_timer.start()
		spawn_timer.start()
		return 

	print("WAVE OVER! Clearing the arena.")
	spawn_timer.stop()
	
	
	for child in get_children():
		if child.has_method("take_damage") and child != player:
			child.queue_free()
			
	
	current_wave += 1
	update_wave_limits()
	
	wave_timer.start()
	spawn_timer.start()
