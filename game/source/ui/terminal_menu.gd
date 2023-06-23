extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_line_edit_text_submitted(new_text: String) -> void:
	new_text = new_text.to_lower()
	
	match new_text:
		"start":
			get_parent().get_parent().open_world() # todo quick hack
			call_deferred("queue_free")
		"settings":
			print("settings")
		"exit":
			get_tree().quit()
		"quit":
			get_tree().quit()
		"credits":
			print("credits")
		
