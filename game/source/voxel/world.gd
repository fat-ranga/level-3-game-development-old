extends World

@onready var main_menu = $CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

const PLAYER := preload("res://scenes/player.tscn")
const PORT: int = 25565
var enet_peer := ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_join_button_pressed() -> void:
	main_menu.hide()
	
	enet_peer.create_client(address_entry.text, PORT)
	print(address_entry.text)
	multiplayer.multiplayer_peer = enet_peer

func _on_host_button_pressed() -> void:
	main_menu.hide()
	
	#upnp_setup()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	
	add_player(multiplayer.get_unique_id())

func add_player(peer_id) -> void:
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	call_deferred("add_child", player)

func remove_player(peer_id) -> void:
	var player = get_node_or_null(str(peer_id))
	if player:
		player.call_deferred("queue_free")

func upnp_setup() -> void:
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover failed! Error %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid gateway!")
	
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port mapping failed. Error %s" % map_result)
	
	print("Success! Join address: %s" % upnp.query_external_address())
