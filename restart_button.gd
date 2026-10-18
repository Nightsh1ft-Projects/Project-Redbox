extends Button

func _pressed():
	
	GameManager.reset_game_data()
	
	get_tree().reload_current_scene()
