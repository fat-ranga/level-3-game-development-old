extends Chunk

var chunk_coords: Vector2i = Vector2i(0, 0)
var world_size_in_blocks: int # Passed from World.
var atlas_size_in_blocks: int
var material: StandardMaterial3D
var texture_ids: Dictionary
var block_types: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Magical C++ functions!
	populate_voxel_map(position, world_size_in_blocks, block_types)
	create_mesh_data(block_types, position, world_size_in_blocks, atlas_size_in_blocks, texture_ids)
	mesh = create_mesh()
	create_trimesh_collision()
	mesh.surface_set_material(0, material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
