extends Chunk

var world = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# TODO: Yucky way to do this.
	world = get_parent()
	
	populate_voxel_map(world)
	create_mesh_data(world)
	mesh = create_mesh()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
