extends Label

# Very bad way to do it, but this is only a debug screen anyway.
@onready var world = get_parent().get_parent().get_parent().get_child(3)
@onready var player = get_parent().get_parent().get_parent().get_child(4)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	text = ""
	
	text += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	
	text += "XYZ: " + str(Vector3i(player.position)) + "\n"
	text += "Current chunk coord: " + str(world.player_current_chunk_coord) + "\n"
	text += "Last chunk coord: " + str(world.player_current_chunk_coord) + "\n"
	text += "Movement State: " + str(player.current_movement_state) + "\n"
	
	text += "Active chunks: " + str(world.active_chunks) + "\n"
	text += "Previously active: " + str(world.previously_active_chunks) + "\n"
	#text += "Chunks: " + str(world.chunks) + "\n"
	#text += "Previously active chunks: " + str(world.previously_active_chunks) + "\n"
