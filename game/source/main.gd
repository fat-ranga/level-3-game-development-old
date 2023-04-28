extends Node

@onready var atlas_packer = $"Atlas Packer"
@onready var data_importer = $"Data Importer"

var current_status: String = ""

@onready var main_menu_scene: PackedScene = preload("res://scenes/ui/main_menu.tscn")
@onready var world_scene: PackedScene = preload("res://scenes/voxel/world.tscn")



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all necessary resources when the game starts.
	load_resources()
	
	# Open up the main menu.
	open_main_menu()

func load_resources() -> void:
	current_status = "Generating texture atlas..."
	var texture_paths: PackedStringArray = atlas_packer.get_texture_paths_in_directory()
	var textures: Array = atlas_packer.load_textures(texture_paths)
	var texture_atlas: Image = atlas_packer.pack_atlas(textures)
	texture_atlas.save_png(Constants.DIRECTORY_USER + "atlas_frfr.png")
	
	current_status = "Reading block types..."
	var block_types: Dictionary = data_importer.get_json_data(Constants.BLOCK_TYPES_PATH)
	#print(block_types.stone.block_name)
	#print(block_types["stone"])

func open_main_menu() -> void:
	
	#call_deferred("add_child", main_menu_scene)
	call_deferred("add_child", main_menu_scene.instantiate()) #TODO: not adding child

func open_world() -> void:
	call_deferred("add_child", world_scene.instantiate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
