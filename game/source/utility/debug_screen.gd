extends Label

# Very bad way to do it, but this is only a debug screen anyway.
@onready var world = get_parent().get_parent().get_parent().get_parent().get_parent().get_child(3)
@onready var player = get_parent().get_parent().get_parent().get_parent().get_parent().get_child(4)

@onready var half_world_size_in_blocks: int = world.world_size_in_blocks / 2
@onready var half_world_size_in_chunks: int = world.world_size_in_chunks / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(player.name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	text = ""
	
	text += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
	
	#text += "XYZ: " + str(Vector3i(player.position) - Vector3i(half_world_size_in_blocks, 0, half_world_size_in_blocks)) + "\n"
	#text += "Current chunk coord: " + str(world.player_current_chunk_coord - Vector2i(half_world_size_in_chunks, half_world_size_in_chunks)) + "\n"
	#text += "Last chunk coord: " + str(world.player_current_chunk_coord - Vector2i(half_world_size_in_chunks, half_world_size_in_chunks)) + "\n"
	text += "XYZ: " + str(Vector3i(player.position)) + "\n"
	text += "Current chunk coord: " + str(world.player_current_chunk_coord) + "\n"
	text += "Last chunk coord: " + str(world.player_current_chunk_coord) + "\n"
	
	text += "Movement State: " + str(player.current_movement_state) + "\n"
	
	text += "Active chunks: " + str(world.active_chunks) + "\n"
	text += "Previously active: " + str(world.previously_active_chunks) + "\n"
	
	var chunk_to_look_at: Chunk = world.chunks[5 * world.world_size_in_chunks + 5]
	
	if chunk_to_look_at:
		text += "Chunk chunks: " + str(chunk_to_look_at.chunks) + "\n"
		text += "Chunk object pointer thing: " + str(chunk_to_look_at.check_for_voxel(Vector3(1,1,1))) + "\n"
	#text += "Chunks: " + str(world.chunks) + "\n"
	#text += "Previously active chunks: " + str(world.previously_active_chunks) + "\n"
