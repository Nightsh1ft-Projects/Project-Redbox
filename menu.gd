extends Node2D


# this is for the start game button
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Main_game.tscn")

# this is for the controls button
func _on_controls_pressed() -> void:
	$Controls_Menu.visible = true

# this is to leave the controls menu
func _on_leave_menu_pressed() -> void:
	$Controls_Menu.visible = false
