extends Node

var texture_ids: Dictionary
var texture_atlas_size_in_pixels: int = Constants.TEXTURE_SIZE # Calculated based on the number of textures imported.
var atlas_size_in_blocks: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func load_texture_atlas():
	var textures = get_texture_paths_in_directory(Constants.TEXTURE_DIRECTORY)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_textures(paths: PackedStringArray) -> Array:
	var image_array: Array
	var images_loaded: int = 0
	var images_not_loaded: int = 0
	
	for texture_path in paths:
		var extension: String = texture_path.get_extension()
		
		if !extension == "png" and !extension == "PNG":
			printerr("Atlas Packer: Texture not PNG: " + texture_path)
			continue # Move on to the next texture_path.
		
		
		
		
		# Read the actual file.
		var new_image = Image.load_from_file(texture_path)
		var image_size = new_image.get_size()
		
		# Move on to the next texture_path if this image is the wrong size.
		if image_size.x != Constants.TEXTURE_SIZE or image_size.y != Constants.TEXTURE_SIZE:
			images_not_loaded += 1
			printerr("Atlas Packer: " + texture_path + " not loaded to atlas: Incorrect size.")
			printerr(str(image_size) + " vs " + str(Constants.TEXTURE_SIZE))
			continue
		
		# We have successfully loaded the image.
		images_loaded += 1
		image_array.append(new_image)
		print(texture_path)
		#print(texture_path)
		
		# Now we add the name of the file to TODO: finish
		var file_name: String = texture_path.get_file()
		#file_name = "cap." + "ranga." + file_name
		var slice_count: int = file_name.get_slice_count(".")
		var file_slice_array: PackedStringArray
		
		# -1 removes the last slice, which is the file extension.
		for i in range(slice_count - 1):
			var slice: String = file_name.get_slice(".", i)
			file_slice_array.append(slice)
		
		# Add back the full stop delimiter to get the original file name without the extension.
		texture_ids[".".join(file_slice_array)] = 0
		#print(".".join(file_slice_array))
		
	
	#print()
	
	# Make the atlas the smallest power of two it can be to fit all the textures.
	while (texture_atlas_size_in_pixels / Constants.TEXTURE_SIZE) * (texture_atlas_size_in_pixels / Constants.TEXTURE_SIZE) < image_array.size():
		texture_atlas_size_in_pixels *= 2
	
	print(texture_atlas_size_in_pixels)
	
	print("Atlas Packer: " + str(images_loaded) + " images successfully loaded to atlas.")
	print("Atlas Packer: " + str(images_not_loaded) + " files not loaded to atlas.")
	return image_array

func pack_atlas(textures: Array) -> ImageTexture:
	var atlas_image = Image.create(texture_atlas_size_in_pixels, texture_atlas_size_in_pixels, false, Image.FORMAT_RGBA8)
	atlas_size_in_blocks = texture_atlas_size_in_pixels / Constants.TEXTURE_SIZE
	#print(atlas_size_in_blocks)
	# We use a modulo operator to increment the row, which is why we start at -1 instead
	# of 0, otherwise the whole first row is skipped.
	var current_row: int = -1
	
	var colour
	var x_offset = 0
	var y_offset = 0
	for t in range(textures.size()):
		#print(str(count) + ": " + str(textures[t]))
		#print(textures[t])
		#print(textures.size())
		
		# This strange-looking syntax makes a new dictionary entry for each texture and assigns it an ID, like this:
		# { grass_top : 3 }
		texture_ids[texture_ids.keys()[t]] = t
		
		if t % atlas_size_in_blocks == 0:
			current_row += 1
		
		x_offset = Constants.TEXTURE_SIZE * t - (texture_atlas_size_in_pixels * current_row)
		y_offset = Constants.TEXTURE_SIZE * current_row
		
		for x in range(Constants.TEXTURE_SIZE):
			for y in range(Constants.TEXTURE_SIZE):
				colour = textures[t].get_pixel(x, y)
				atlas_image.set_pixel(x + x_offset, y + y_offset, colour)
	
	# Convert it from an Image to a Texture2D for use in a StandardMaterial3D.
	var final_texture: ImageTexture = ImageTexture.create_from_image(atlas_image)
	return final_texture

func get_texture_paths_in_directory(root_directory: String = Constants.TEXTURE_DIRECTORY) -> PackedStringArray:
	#print(root_directory)
	
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
