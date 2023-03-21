extends Node

@onready var atlas_packer = $"Atlas Packer"
@onready var data_importer = $"Data Importer"

var current_status: String = ""

@onready var main_menu_scene = "res://scenes/ui/main_menu.tscn" # TODO: figure out type, not PackedScene?

@onready var ROOT_DIRECTORY: String = str(OS.get_executable_path().get_base_dir())
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
	data_importer.get_json_data(BLOCK_TYPES_PATH)

func open_main_menu() -> void:
	
	call_deferred("add_child", main_menu_scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
