extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_json_data(path: String) -> Dictionary:
	var data_file = FileAccess.open(path, FileAccess.READ)
	var json_data = JSON.parse_string(data_file.get_as_text())
	
	# TODO: More robust error-checking: right now we only get an invalid get index.
	return json_data

