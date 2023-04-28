extends Chunk

var block_types: Array = ["cap", "ong fr fr"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_voxel_map()
	create_mesh_data()
	mesh = create_mesh()
	create_trimesh_collision()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
