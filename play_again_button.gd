extends Button

func _pressed():
	
	GameManager.reset_game_data()
	
	
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")


func _on_main_menu_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu.tscn")
