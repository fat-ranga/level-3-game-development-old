extends Node

const TEXTURE_SIZE: int = 16
const TEXTURE_ATLAS_SIZE: int = 64 # Only works in multiples of the TEXTURE_SIZE.

	
# Different root directories for storing game data such as textures and stuff.
# We have these because it's easier to work on the game in editor using the local resource directory.
# When we export the game, we can't write to res:// anymore, so we need to use either the user directory
# or the directory where the actual game exe is stored.
@onready var DIRECTORY_RES = "res://data"
@onready var DIRECTORY_LOCAL_EXECUTABLE = str(OS.get_executable_path().get_base_dir())
@onready var DIRECTORY_USER = "user://"

@onready var ROOT_DIRECTORY: String = DIRECTORY_LOCAL_EXECUTABLE


@onready var BLOCK_TYPES_PATH: String = str(ROOT_DIRECTORY + "/block_types.json")#"user://textures"
@onready var TEXTURE_DIRECTORY: String = str(ROOT_DIRECTORY + "/textures/atlas")#"user://textures"
