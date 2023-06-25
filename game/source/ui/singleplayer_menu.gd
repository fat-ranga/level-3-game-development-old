extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_parent().hide()
	hide()
	EventBus.host_game.emit(false)


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
