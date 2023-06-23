extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("Start2").grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_start_2_pressed() -> void:
	get_parent().get_parent().open_world()
	get_parent().hide()
