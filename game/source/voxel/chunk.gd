extends Chunk

var block_types: Dictionary = {
	"stone":
		{"is_solid":false,
		"transparent":false
		},
	"air":
		{"is_solid":true,
		"transparent":false
		}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var number = block_types.keys()[0]
	
	#print(block_types[number]["is_solid"])
	
	populate_voxel_map()
	create_mesh_data(block_types)
	mesh = create_mesh()
	create_trimesh_collision()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
