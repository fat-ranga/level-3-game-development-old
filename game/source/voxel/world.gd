extends World

# Voxel stuff.
#class BlockType:
#	var block_name: String
#	var is_solid: bool
#
##@export var material: Material
#var ranga: BlockType = BlockType.new() # could be stone, etc.
#var blocktypes: Array = [] # array of all the types of blocks we have in the game.

var seed: String = "0"
var block_types: Dictionary # JSON passed from Main.
var world_size_in_chunks: int = 10 # Must be even!

# These are passed from Main, after the texture atlas packer has done its thing.
var texture_atlas
var atlas_size_in_blocks: int
var texture_ids: Dictionary

var biomes: Dictionary

@onready var world_size_in_blocks = world_size_in_chunks * Constants.CHUNK_WIDTH

var chunks: Array # Generated in _ready().
var active_chunks: Array
var chunks_to_generate: Array
var chunks_to_remesh: Array

var player: Node3D
var player_last_chunk_coord: Vector2i
var player_current_chunk_coord: Vector2i
var previously_active_chunks: Array

@onready var chunk_scene = preload("res://scenes/voxel/chunk.tscn")
@onready var chunk_container = $Chunks
var chunk_material: StandardMaterial3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#EventBus.host_game.connect(host_game)
	#EventBus.join_game.connect(join_game)
	#var new_chunk: Chunk = chunk_scene.instantiate()
	
	
	chunks.resize(world_size_in_chunks * world_size_in_chunks)
	chunks.fill(null)
	# set value
	#chunks[x + z * world_size_in_chunks]
	#var fully = Time.get_ticks_usec()
	generate_world()
	player_last_chunk_coord = Vector2i(player.position.x, player.position.z)
	player.block_outline = $BlockOutline
	player.world = self
	#var cap = Time.get_ticks_usec()
	#print(cap - fully)
	#print(block_types)
	#print(new_chunk.block_types)
	
	#chunk_container.add_child(new_chunk)

func generate_world() -> void:
	# Only run when the world is first launched.
	
	for x in range((world_size_in_chunks / 2) - Constants.VIEW_DISTANCE, (world_size_in_chunks / 2) + Constants.VIEW_DISTANCE):
		for z in range((world_size_in_chunks / 2) - Constants.VIEW_DISTANCE, (world_size_in_chunks / 2) + Constants.VIEW_DISTANCE):
			#create_new_chunk(x, z)
			#chunks[x * world_size_in_chunks + z] = initialise_chunk(x, z)
			chunks_to_generate.append(Vector2i(x, z))
	

func initialise_chunk(x: int, z: int) -> Chunk:
	var new_chunk: Chunk = chunk_scene.instantiate()
	
	new_chunk.chunks = chunks
	new_chunk.world_size_in_voxels = world_size_in_blocks
	new_chunk.chunk_coords = Vector2i(x, z)
	new_chunk.position = Vector3(new_chunk.chunk_coords.x * Constants.CHUNK_WIDTH,
	0.0,
	new_chunk.chunk_coords.y * Constants.CHUNK_WIDTH)
	new_chunk.name = "Chunk " + str(new_chunk.chunk_coords)
	new_chunk.block_types = block_types
	new_chunk.material = chunk_material
	new_chunk.texture_atlas_size_in_blocks = atlas_size_in_blocks
	new_chunk.texture_ids = texture_ids
	new_chunk.biomes = biomes
	
	return new_chunk

func generate_chunk() -> void:
	var chunk: Chunk = initialise_chunk(chunks_to_generate[0].x, chunks_to_generate[0].y)
	
	chunk.populate_voxel_map(chunk.position)
	chunk.update_chunk()
	chunk.mesh = chunk.create_mesh()
	chunk.mesh.surface_set_material(0, chunk.material)
	chunk.create_trimesh_collision()
	#chunk.generate_mesh()
	#chunk.generate_collider()
	
	chunks[chunks_to_generate[0].x * world_size_in_chunks + chunks_to_generate[0].y] = chunk
	chunk_container.call_deferred("add_child", chunk)
	active_chunks.append(Vector2i(chunks_to_generate[0].x, chunks_to_generate[0].y))
	
	print("generated chunk" + str(chunks_to_generate[0]))
	
	chunks_to_generate.remove_at(0)

#func remesh_chunks() -> void:
#	for i in range(chunks_to_remesh):
#		chunks_to_remesh[i].clear_mesh()

func get_chunk_coord_from_vector3(pos: Vector3) -> Vector2i:
	var x: int = floori(pos.x / Constants.CHUNK_WIDTH)
	var z: int = floori(pos.z / Constants.CHUNK_WIDTH)
	
	return Vector2i(x, z)

func get_chunk_from_vector3(pos: Vector3) -> Chunk:
	var x: int = floori(pos.x / Constants.CHUNK_WIDTH)
	var z: int = floori(pos.z / Constants.CHUNK_WIDTH)
	
	
	return chunks[x * world_size_in_chunks + z]

func check_view_distance() -> void:
	var coord: Vector2i = get_chunk_coord_from_vector3(player.position)
	

	previously_active_chunks.clear()
	previously_active_chunks.append_array(active_chunks)

	active_chunks.clear()
	
	var things_to_remove: Array = []
	
	for x in range(coord.x - Constants.VIEW_DISTANCE, coord.x + Constants.VIEW_DISTANCE):
		for z in range(coord.y - Constants.VIEW_DISTANCE, coord.y + Constants.VIEW_DISTANCE):
			if is_chunk_in_world(x, z):
				var chunk: Chunk = chunks[x * world_size_in_chunks + z]
				
				if chunk == null:
					chunks_to_generate.append(Vector2i(x, z))
					#create_new_chunk(x, z)
				elif !chunk.visible:
					chunk.show()
				
				active_chunks.append(Vector2i(x, z))
			
			for i in range(previously_active_chunks.size()):
				if not i > previously_active_chunks.size() - 1: # Took me way too long to come up with this check.
					if previously_active_chunks[i] == Vector2i(x, z):
						previously_active_chunks.remove_at(i)
	
	for c in previously_active_chunks:
		if c == player_last_chunk_coord or c == player_current_chunk_coord:
			continue
		chunks[c.x * world_size_in_chunks + c.y].hide()


func is_chunk_in_world(x: int, z: int) -> bool:
	if x >= 0 && x < world_size_in_chunks && z >= 0 && z < world_size_in_chunks:
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Only update what chunks to load/unload if the player has actually moved.
	
	while chunks_to_generate.size() > 0:
		generate_chunk()
	
	player_current_chunk_coord = get_chunk_coord_from_vector3(player.position)
	
	if player_current_chunk_coord != player_last_chunk_coord:
		check_view_distance()
	
	player_last_chunk_coord = player_current_chunk_coord
	
