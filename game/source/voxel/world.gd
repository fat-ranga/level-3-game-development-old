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

@onready var chunk_scene = preload("res://scenes/voxel/chunk.tscn")
@onready var chunk_container = $Chunks


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#EventBus.host_game.connect(host_game)
	#EventBus.join_game.connect(join_game)
	var new_chunk: Chunk = chunk_scene.instantiate()
	new_chunk.chunk_coords = Vector2i(1, 0)
	new_chunk.name = "Chunk " + str(new_chunk.chunk_coords)
	new_chunk.block_types = block_types
	#print(block_types)
	#print(new_chunk.block_types)
	
	chunk_container.add_child(new_chunk)
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

