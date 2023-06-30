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
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var block_types: Dictionary # JSON passed from Main.
var world_size_in_chunks: int = 20 # Must be even!
@onready var world_size_in_blocks = world_size_in_chunks * Constants.CHUNK_WIDTH
var chunks: Array # Generated in _ready().
var active_chunks: Array
var player: Node3D
var player_last_chunk_coord: Vector2i
var player_current_chunk_coord: Vector2i

@onready var chunk_scene = preload("res://scenes/voxel/chunk.tscn")
@onready var chunk_container = $Chunks

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#EventBus.host_game.connect(host_game)
	#EventBus.join_game.connect(join_game)
	#var new_chunk: Chunk = chunk_scene.instantiate()
	
	rng.seed = hash(seed)
	
	chunks.resize(world_size_in_chunks * world_size_in_chunks)
	chunks.fill(null)
	# set value
	#chunks[x + z * world_size_in_chunks]
	#var fully = Time.get_ticks_usec()
	generate_world()
	player_last_chunk_coord = Vector2i(player.position.x, player.position.z)
	#var cap = Time.get_ticks_usec()
	#print(cap - fully)
	#print(block_types)
	#print(new_chunk.block_types)
	
	#chunk_container.add_child(new_chunk)

func generate_world() -> void:
	# Only run when the world is first launched.
	
	for x in range((world_size_in_chunks / 2) - Constants.VIEW_DISTANCE, (world_size_in_chunks / 2) + Constants.VIEW_DISTANCE):
		for z in range((world_size_in_chunks / 2) - Constants.VIEW_DISTANCE, (world_size_in_chunks / 2) + Constants.VIEW_DISTANCE):
			create_new_chunk(x, z)
	
	#print(block_types["stone"].keys())
	

func create_new_chunk(x: int, z: int) -> void:
	var new_chunk: Chunk = chunk_scene.instantiate()
	
	new_chunk.world_size_in_blocks = world_size_in_blocks
	new_chunk.chunk_coords = Vector2i(x, z)
	new_chunk.position = Vector3(new_chunk.chunk_coords.x * Constants.CHUNK_WIDTH,
	0.0,
	new_chunk.chunk_coords.y * Constants.CHUNK_WIDTH)
	new_chunk.name = "Chunk " + str(new_chunk.chunk_coords)
	new_chunk.block_types = block_types
	
	# Indexing like this because it is one, not two-dimensional.
	#var fully = Time.get_ticks_usec()
	chunks[x * world_size_in_chunks + z] = new_chunk
	
	
	chunk_container.call_deferred("add_child", new_chunk)
	active_chunks.append(Vector2i(x, z))

func get_chunk_coord_from_vector3(pos: Vector3) -> Vector2i:
	var x: int = floori(pos.x / Constants.CHUNK_WIDTH)
	var z: int = floori(pos.z / Constants.CHUNK_WIDTH)
	
	return Vector2i(x, z)

func check_view_distance() -> void:
	var coord: Vector2i
	
	coord = get_chunk_coord_from_vector3(player.position)
	#coord = get_chunk_coord_from_vector3(Vector3())
	
	# We append it this way so that we aren't just passing a reference around.
	var previously_active_chunks: Array
	previously_active_chunks.append_array(active_chunks)
	
	for x in range(coord.x - Constants.VIEW_DISTANCE, coord.x + Constants.VIEW_DISTANCE):
		for z in range(coord.y - Constants.VIEW_DISTANCE, coord.y + Constants.VIEW_DISTANCE):
			if is_chunk_in_world(x, z):
				if chunks[x * world_size_in_chunks + z] == null:
					create_new_chunk(x, z)
				else:
					chunks[x * world_size_in_chunks + z].show()
				
				# Check if the chunk is disabled or not.
				#elif chunks[x * world_size_in_chunks + z]:
					#chunks[x * world_size_in_chunks + z].process_mode = PROCESS_MODE_INHERIT
					#chunks[x * world_size_in_chunks + z].show()
					#active_chunks.append(Vector2i(x, z))
			
			#print("before")
			#print(previously_active_chunks)
			
			# Remove chunks that are within the view distance.
			for i in range(previously_active_chunks.size() - 1):
				if previously_active_chunks[i] == Vector2i(x, z):
					previously_active_chunks.remove_at(i)
	
	for c in previously_active_chunks:
		#chunks[c.x * world_size_in_chunks + c.y].process_mode = PROCESS_MODE_DISABLED
		chunks[c.x * world_size_in_chunks + c.y].hide()

					

func is_chunk_in_world(x: int, z: int) -> bool:
	if x > 0 && x < world_size_in_chunks - 1 && z > 0 && z < world_size_in_chunks - 1:
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	# Only update what chunks to load/unload if the player has actually moved.
	
	player_current_chunk_coord = Vector2i(player.position.x, player.position.z)
	
	if player_current_chunk_coord != player_last_chunk_coord:
		check_view_distance()
	
	player_last_chunk_coord = player_current_chunk_coord
