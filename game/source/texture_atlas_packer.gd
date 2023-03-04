extends Node

const TEXTURE_SIZE: int = 16
const TEXTURE_ATLAS_SIZE: int = 48
const TEXTURE_DIRECTORY: String = "user://textures"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func load_texture_atlas():
	var textures = get_texture_paths_in_directory(TEXTURE_DIRECTORY)
	print(textures)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_textures(paths: PackedStringArray) -> Array:
	var image_array: Array
	
	for texture_path in paths:
		var new_image = Image.load_from_file(texture_path)
		var image_size = new_image.get_size()
		
		if image_size.x != TEXTURE_SIZE or image_size.y != TEXTURE_SIZE:
			printerr(texture_path + " not loaded to atlas: Incorrect size.")
			printerr(str(image_size) + " vs " + str(TEXTURE_SIZE))
			continue
		
		image_array.append(new_image)
	return image_array

func pack_atlas(textures: Array) -> ImageTexture:
	var temp_atlas = Image.create(TEXTURE_ATLAS_SIZE, TEXTURE_ATLAS_SIZE, false, Image.FORMAT_RGBA8)
	var pixels: PackedColorArray
	
	var atlas_size_in_blocks = TEXTURE_ATLAS_SIZE / TEXTURE_SIZE
	var current_row: int = 0
	
	var current_texture_index = 0
	
	for x in range(TEXTURE_ATLAS_SIZE):
		for y in range(TEXTURE_ATLAS_SIZE):
			var colour = Color(0, 0, 0, 0)
			
			var texture_x: int = x / TEXTURE_SIZE
			var texture_y: int = y / TEXTURE_SIZE
			
			#current_texture_index = texture_y * 16 + texture_x
			#current_texture_index = texture_y * 16 + (texture_x / atlas_size_in_blocks)
			
			current_row = current_texture_index / atlas_size_in_blocks
			
			
			
			print(current_texture_index)
			
			if current_texture_index > textures.size() - 1:
				colour = Color(0, 0, 0, 0)
			else:
				# Divide by current block.
				#colour = textures[current_texture].get_pixel(x / (current_texture + 1), y / (current_texture + 1))
				colour = textures[current_texture_index].get_pixel(x - (TEXTURE_SIZE * current_texture_index), y + (2 * current_texture_index))
			
			temp_atlas.set_pixel(x, y, colour)
	
	var atlas_texture: ImageTexture
	
	temp_atlas.save_png("user://ranga.png")
	
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
