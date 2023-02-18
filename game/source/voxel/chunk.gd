extends Chunk

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_voxel_map()
	create_mesh_data()
	mesh = create_mesh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
