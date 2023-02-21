extends Node

@onready var atlas_packer = $"Atlas Packer"

var current_status: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Load all necessary resources when the game starts.
	load_resources()

func load_resources() -> void:
	current_status = "Generating texture atlas..."
	var texture_paths: PackedStringArray = atlas_packer.get_texture_paths_in_directory()
	var textures = atlas_packer.load_textures(texture_paths)
	var texture_atlas: ImageTexture = atlas_packer.pack_atlas(textures)
	
	
	
	current_status = "Texture atlas generated."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
