extends World

# Voxel stuff.
#class BlockType:
#	var block_name: String
#	var is_solid: bool
#
##@export var material: Material
#var ranga: BlockType = BlockType.new() # could be stone, etc.
#var blocktypes: Array = [] # array of all the types of blocks we have in the game.

var block_types: Dictionary # JSON passed from Main.
var world_size_in_chunks: int = 5
@onready var world_size_in_blocks = world_size_in_chunks * Constants.CHUNK_WIDTH
var chunks: Array # Generated in _ready().

@onready var chunk_scene = preload("res://scenes/voxel/chunk.tscn")
@onready var chunk_container = $Chunks


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#EventBus.host_game.connect(host_game)
	#EventBus.join_game.connect(join_game)
	#var new_chunk: Chunk = chunk_scene.instantiate()
	
	chunks.resize(world_size_in_chunks * world_size_in_chunks)
	chunks.fill(0)
	# set value
	#chunks[x + z * world_size_in_chunks]
	
	generate_world()
	
	#print(block_types)
	#print(new_chunk.block_types)
	
	#chunk_container.add_child(new_chunk)

func generate_world() -> void:
	# Only run when the world is first launched.
	
	for x in range(world_size_in_chunks):
		for z in range(world_size_in_chunks):
			create_new_chunk(x, z)
	

func create_new_chunk(x: int, z: int) -> void:
	var new_chunk: Chunk = chunk_scene.instantiate()
	
	new_chunk.chunk_coords = Vector2i(x, z)
	new_chunk.position = Vector3(new_chunk.chunk_coords.x * Constants.CHUNK_WIDTH,
	0.0,
	new_chunk.chunk_coords.y * Constants.CHUNK_WIDTH)
	new_chunk.name = "Chunk " + str(new_chunk.chunk_coords)
	new_chunk.block_types = block_types
	
	# Indexing like this because it is one, not two-dimensional.
	chunks[x + z * world_size_in_chunks] = new_chunk
	
	chunk_container.call_deferred("add_child", new_chunk)

func is_chunk_in_world(coord: Vector2i) -> bool:
	if not coord.x > 0 && coord.x < world_size_in_chunks - 1:
		return false
	if not coord.y > 0 && coord.y < world_size_in_chunks - 1:
		return false
	
	return true

func is_voxel_in_world(pos: Vector3) -> bool:
	if not pos.x > 0 && pos.x < world_size_in_blocks - 1:
		return false
	if not pos.y > 0 && pos.y < Constants.CHUNK_HEIGHT - 1:
		return false
	if not pos.z > 0 && pos.z < world_size_in_blocks - 1:
		return false
	
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

