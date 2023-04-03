extends Node

const TEXTURE_SIZE: int = 16
const TEXTURE_ATLAS_SIZE: int = 48 # Only works in multiples of the TEXTURE_SIZE.
# TODO: change this to a global constant or something.
@onready var ROOT_DIRECTORY: String = str(OS.get_executable_path().get_base_dir())
@onready var TEXTURE_DIRECTORY: String = str(ROOT_DIRECTORY + "/textures/atlas")#"user://textures"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(TEXTURE_DIRECTORY)

func load_texture_atlas():
	var textures = get_texture_paths_in_directory(TEXTURE_DIRECTORY)
	print(textures)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_textures(paths: PackedStringArray) -> Array:
	var image_array: Array
	var images_loaded: int = 0
	var images_not_loaded: int = 0
	
	for texture_path in paths:
		# TODO: Add error check for anything other than pngs.
		var new_image = Image.load_from_file(texture_path)
		var image_size = new_image.get_size()
		
		if image_size.x != TEXTURE_SIZE or image_size.y != TEXTURE_SIZE:
			images_not_loaded += 1
			printerr(texture_path + " not loaded to atlas: Incorrect size.")
			printerr(str(image_size) + " vs " + str(TEXTURE_SIZE))
		else:
			images_loaded += 1
		
		image_array.append(new_image)
	print("Atlas Packer: " + str(images_loaded) + " images successfully loaded to atlas.")
	print("Atlas Packer: " + str(images_not_loaded) + " files not loaded to atlas.")
	return image_array

func pack_atlas(textures: Array) -> ImageTexture:
	var temp_atlas = Image.create(TEXTURE_ATLAS_SIZE, TEXTURE_ATLAS_SIZE, false, Image.FORMAT_RGBA8)
	var atlas_size_in_blocks = TEXTURE_ATLAS_SIZE / TEXTURE_SIZE

	# We use a modulo operator to increment the row, which is why we start at -1 instead
	# of 0, otherwise the whole first row is skipped.
	var current_row: int = -1
	
	var colour
	var x_offset = 0
	var y_offset = 0
	for t in range(textures.size() - 1):
		if t % atlas_size_in_blocks == 0:
			current_row += 1
		
		x_offset = TEXTURE_SIZE * t - (TEXTURE_ATLAS_SIZE * current_row)
		y_offset = TEXTURE_SIZE * current_row
		
		for x in range(TEXTURE_SIZE):
			for y in range(TEXTURE_SIZE):
				colour = textures[t].get_pixel(x, y)
				temp_atlas.set_pixel(x + x_offset, y + y_offset, colour)
	var atlas_texture: ImageTexture
	
	temp_atlas.save_png("user://ranga.png") # TODO: how is this resource going to be accessed? Sort out GameData singleton or something.
	
	return atlas_texture

func get_texture_paths_in_directory(root_directory: String = TEXTURE_DIRECTORY) -> PackedStringArray:
	var files: PackedStringArray = []
	var directories: PackedStringArray = []
	var dir = DirAccess.open(root_directory)
	
	dir.list_dir_begin()
	_add_dir_contents(dir, files, directories)

	return files

func _add_dir_contents(dir: DirAccess, files: PackedStringArray, directories: PackedStringArray):
	var file_name = dir.get_next()
	
	# If there's no file, the while loop ends.
	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name
		
		# Checks whether the current path is a folder or a file.
		if dir.current_is_dir():
			print("Atlas Packer: Found directory: %s" % path)
			var subDir = DirAccess.open(path)
			subDir.list_dir_begin()
			directories.append(path)
			_add_dir_contents(subDir, files, directories)
		else:
			print("Atlas Packer: Found file: %s" % path)
			files.append(path)
		
		# Get the next file in the directory.
		file_name = dir.get_next()
	
	dir.list_dir_end()
