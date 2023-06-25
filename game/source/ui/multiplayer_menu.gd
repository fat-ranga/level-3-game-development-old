extends Control


@onready var world_scene = load("res://scenes/voxel/world.tscn")
@onready var address_entry = $VBoxContainer/VBoxContainer/AddressEntry
@onready var port = $VBoxContainer/VBoxContainer/Port

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_host_button_pressed() -> void:
	get_parent().hide()
	hide()
	#get_parent().get_parent().open_world() # Horrendous way to do it.
	#call_deferred("add_child", world_scene.instantiate())
	#world_scene.instantiate()
	
	#call_deferred("add_child", world_scene.instantiate())
	
	EventBus.host_game.emit(int(port.text), true)


func _on_join_button_pressed() -> void:
	get_parent().hide()
	hide()
	EventBus.join_game.emit(address_entry.text, int(port.text))
