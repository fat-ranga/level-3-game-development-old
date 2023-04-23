extends Node

@onready var atlas_packer = $"Atlas Packer"
@onready var data_importer = $"Data Importer"

var current_status: String = ""

<<<<<<< Updated upstream
@onready var main_menu_scene: PackedScene = load("res://scenes/ui/main_menu.tscn") # TODO: figure out type, not PackedScene?
@onready var world_scene: PackedScene = load("res://scenes/voxel/world.tscn")
=======
@onready var main_menu_scene: PackedScene = preload("res://scenes/ui/main_menu.tscn")
@onready var world_scene: PackedScene = preload("res://scenes/voxel/world.tscn")
>>>>>>> Stashed changes

# Different root directories for storing game data such as textures and stuff.
# We have these because it's easier to work on the game in editor using the local resource directory.
# When we export the game, we can't write to res:// anymore, so we need to use either the user directory
# or the directory where the actual game exe is stored.
@onready var DIRECTORY_RES = "res://"
@onready var DIRECTORY_LOCAL_EXECUTABLE = str(OS.get_executable_path().get_base_dir())
@onready var DIRECTORY_USER = "user://"

@onready var ROOT_DIRECTORY: String = DIRECTORY_RES

@onready var BLOCK_TYPES_PATH: String = str(ROOT_DIRECTORY + "/block_types.json")#"user://textures"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all necessary resources when the game starts.
	#load_resources()
	
	# Open up the main menu.
	open_main_menu()

func load_resources() -> void:
	current_status = "Generating texture atlas..."
	var texture_paths: PackedStringArray = atlas_packer.get_texture_paths_in_directory()
	var textures: Array = atlas_packer.load_textures(texture_paths)
	var texture_atlas: ImageTexture = atlas_packer.pack_atlas(textures)
	
	current_status = "Reading block types..."
	var block_types = data_importer.get_json_data(BLOCK_TYPES_PATH)
	print(block_types.stone.block_name)

func open_main_menu() -> void:
	
	#call_deferred("add_child", main_menu_scene)
<<<<<<< Updated upstream
	#call_deferred("add_child", main_menu_scene)
	add_child(world_scene.instantiate())
	#call_deferred("add_child") #TODO: not adding child
=======
	call_deferred("add_child", main_menu_scene.instantiate()) #TODO: not adding child
>>>>>>> Stashed changes

func open_world() -> void:
	print("ong")
	call_deferred("add_child", world_scene.instantiate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
