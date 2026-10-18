extends Control

func _process(_delta):
	
	if visible:
		
		for child in get_children():
			if child is Label:
				
				if "Survived" in child.name or "Time" in child.name:
					child.text = "Endless Time Survived: " + str(ceil(GameManager.endless_time_survived)) + " seconds"
