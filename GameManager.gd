extends Node

var total_kills = 0
var current_wave = 1 
var endless_time_survived = 0.0 
var is_player_dead = false 

func _ready():
	reset_game_data()

func reset_game_data():
	total_kills = 0
	current_wave = 1
	endless_time_survived = 0.0
	is_player_dead = false
	print("🔄 GameManager: Active run stats successfully cleared and reset!")

func _process(delta):
	if current_wave >= 10 and not is_player_dead:
		endless_time_survived += delta

func enemy_killed():
	total_kills += 1
	print("Horde kill tracked! Total: ", total_kills)


func trigger_player_death_ui():
	is_player_dead = true
	

	var living_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy_clone in living_enemies:
		if is_instance_valid(enemy_clone):
			enemy_clone.queue_free()
			

	var root = get_tree().current_scene
	var debug_panel = root.find_child("DebugPanel", true, false)
	if debug_panel: debug_panel.visible = false

	
	if current_wave >= 10:
		var wave_10_screen = root.find_child("Wave10Screen", true, false)
		if wave_10_screen:
			wave_10_screen.visible = true
			
			var kill_label = wave_10_screen.find_child("KillCountLabel", true, false)
			if kill_label: kill_label.text = "Total Rectangle Kills: " + str(total_kills)
			
			var time_label = wave_10_screen.find_child("TimeSurvivedLabel", true, false)
			if time_label: 
				time_label.text = "Endless Time Survived: " + str(ceil(endless_time_survived)) + " seconds"
		else:
			print("🚨 ERROR: GameManager could not find 'Wave10Screen' node!")
	else:
		var standard_screen = root.find_child("DeathScreen", true, false)
		if standard_screen:
			standard_screen.visible = true
			var kill_label = standard_screen.find_child("KillCountLabel", true, false)
			if kill_label: kill_label.text = "Total Rectangle Kills: " + str(total_kills)
		else:
			print("🚨 ERROR: GameManager could not find 'DeathScreen' node!")

func _on_restart_button_pressed():
	reset_game_data()
	
	get_tree().change_scene_to_file("res://Node_2d2.tscn") 


func _on_play_again_button_pressed():
	reset_game_data()
	get_tree().change_scene_to_file("res://Node_2d2.tscn")

	
