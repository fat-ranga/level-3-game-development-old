extends Chunk

var chunk_coords: Vector2i = Vector2i(0, 0)


var block_types: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(block_types)
	
	populate_voxel_map()
	create_mesh_data(block_types)
	mesh = create_mesh()
	create_trimesh_collision()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
