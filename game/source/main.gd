extends Node

@onready var atlas_packer = $"Atlas Packer"
@onready var data_importer = $"Data Importer"

var current_status: String = ""

@onready var main_menu_scene: PackedScene = preload("res://scenes/ui/main_menu.tscn")
@onready var world_scene: PackedScene = preload("res://scenes/voxel/world.tscn")

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
	current_status = "Reading textures..."
	var texture_paths: PackedStringArray = atlas_packer.get_texture_paths_in_directory()
	var textures: Array = atlas_packer.load_textures(texture_paths)
	
	current_status = "Generating texture atlas..."
	var texture_atlas: Image = atlas_packer.pack_atlas(textures)
	texture_atlas.save_png(Constants.DIRECTORY_USER + "atlas_frfr.png")
	
	current_status = "Reading block types..."
	var block_types: Dictionary = data_importer.get_json_data(Constants.BLOCK_TYPES_PATH)
	#print(block_types.stone.block_name)
	#print(block_types["stone"].is_solid)
	#print(block_types["stone"])

func open_main_menu() -> void:
	
	#call_deferred("add_child", main_menu_scene)
	call_deferred("add_child", main_menu_scene.instantiate())
	
	
	

func open_world() -> void:
	print("world opened")
	
	call_deferred("add_child", world_scene.instantiate())

####################
# NETWORKING
#################

func join_game(ip: String, port) -> void:
	#main_menu.hide()
	call_deferred("add_child", world_scene.instantiate())
	
	enet_peer.create_client(ip, port)
	print(ip)
	multiplayer.multiplayer_peer = enet_peer
	

func host_game(port) -> void:
	#main_menu.hide()
	call_deferred("add_child", world_scene.instantiate())
	
	print("game started")
	
	upnp_setup(port) #TODO: enable this if actually using multiplayer
	
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

func add_player(peer_id) -> void:
	print("Player added")
	
	var player = PLAYER.instantiate()
	print("1")
	player.name = str(peer_id)
	print("2")
	call_deferred("add_child", player)
	print("3")

func remove_player(peer_id) -> void:
	print("Player removed")
	
	var player = get_node_or_null(str(peer_id))
	if player:
		player.call_deferred("queue_free")

func upnp_setup(port) -> void:
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
