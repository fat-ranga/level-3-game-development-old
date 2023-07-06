extends Node

@onready var atlas_packer = $"Atlas Packer"
@onready var data_importer = $"Data Importer"

var current_status: String = ""

@onready var main_menu_scene: PackedScene = preload("res://scenes/ui/main_menu.tscn")
@onready var world_scene: PackedScene = preload("res://scenes/voxel/world.tscn")

var world: World

var player_spawn_position: Vector3 # Calculated after the world is instantiated.

# Networking stuff.
const PLAYER := preload("res://scenes/player.tscn")
#const PORT: int = 25565 # Same as Minecraft.
var enet_peer := ENetMultiplayerPeer.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.host_game.connect(host_game)
	EventBus.join_game.connect(join_game)
	
	
	# Load all necessary resources when the game starts.
	load_resources()
	
	# Open up the main menu.
	open_main_menu()

func load_resources() -> void:
	world = world_scene.instantiate() # Prepare the world so we can send data to it.
	
	current_status = "Reading textures..."
	var texture_paths: PackedStringArray = atlas_packer.get_texture_paths_in_directory()
	var textures: Array = atlas_packer.load_textures(texture_paths)
	
	current_status = "Generating texture atlas..."
	var texture_atlas: ImageTexture = atlas_packer.pack_atlas(textures)
	#texture_atlas.save_png(Constants.DIRECTORY_LOCAL_EXECUTABLE + "atlas_frfr.png")
	world.atlas_size_in_blocks = atlas_packer.atlas_size_in_blocks
	world.texture_ids = atlas_packer.texture_ids
	
	var chunk_material: StandardMaterial3D = StandardMaterial3D.new()
	#chunk_material.vertex_color_use_as_albedo = true
	chunk_material.albedo_texture = texture_atlas
	chunk_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	world.chunk_material = chunk_material
	
	#print(atlas_packer.texture_ids)
	
	current_status = "Reading block types..."
	var block_types: Dictionary = data_importer.get_json_data(Constants.BLOCK_TYPES_PATH)
	data_importer.add_block_type_numeric_ids(block_types)
	player_spawn_position = Vector3((world.world_size_in_chunks * Constants.CHUNK_WIDTH) / 2, Constants.CHUNK_HEIGHT, (world.world_size_in_chunks * Constants.CHUNK_WIDTH) / 2)
	world.block_types = block_types
	#print(world.block_types)
	
	current_status = "Reading biomes..."
	var biomes: Dictionary = data_importer.get_json_data(Constants.BIOMES_PATH)
	world.biomes = biomes
	
	#print(block_types)
	
	#print(block_types.stone.block_name)
	#print(block_types["stone"].is_solid)
	#print(block_types["stone"])

func open_main_menu() -> void:
	
	#call_deferred("add_child", main_menu_scene)
	call_deferred("add_child", main_menu_scene.instantiate())

####################
# NETWORKING
#################

func join_game(ip: String, port) -> void:
	call_deferred("add_child", world)
	
	enet_peer.create_client(ip, port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())
	

func host_game(port=25565, is_multiplayer=false) -> void:
	#main_menu.hide()
	call_deferred("add_child", world)
	
	if is_multiplayer:
		upnp_setup(port)
	
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

func add_player(peer_id) -> void:
	print("Player added: " + str(peer_id))
	
	var player: Node3D = PLAYER.instantiate()
	world.player = player
	player.position = player_spawn_position
	player.name = str(peer_id)
	call_deferred("add_child", player)

func remove_player(peer_id) -> void:
	print("Player removed: " + str(peer_id))
	
	var player = get_node_or_null(str(peer_id))
	if player:
		player.call_deferred("queue_free")

func upnp_setup(port) -> void:
	print("begin upnp setup")
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid gateway!")
	
	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port mapping failed. Error %s" % map_result)
	
	print("Success! Join address: %s" % upnp.query_external_address())
