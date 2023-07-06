extends Chunk

# Passed from World.
var chunk_coords: Vector2i = Vector2i(0, 0)
#var world_size_in_blocks: int
#var atlas_size_in_blocks: int
var material: StandardMaterial3D
##var texture_ids: Dictionary
#var block_types: Dictionary
#var biomes: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass
	#biomes
	pass

	#get_biomes()
	#texture_atlas_size_in_blocks = 5
	# Magical C++ functions!
	#populate_voxel_map(position, world_size_in_blocks, block_types, biomes)
	#create_mesh_data(block_types, position, world_size_in_blocks, atlas_size_in_blocks, texture_ids, biomes)
	#mesh = create_mesh()
	#create_trimesh_collision()
	#mesh.surface_set_material(0, material)

func update() -> void:
	mesh = null
	update_chunk()
	mesh = create_mesh()
	mesh.surface_set_material(0, material)
	for c in get_children(): # Delete the old collision shape.
		c.queue_free()
	create_trimesh_collision()

#func generate_terrain() -> void:
#	#pass
#	populate_voxel_map(position)
#
#func generate_mesh() -> void:
#	create_mesh_data()
#	mesh = create_mesh()
#	mesh.surface_set_material(0, material)
#
#func generate_collider() -> void:
#	create_trimesh_collision()
