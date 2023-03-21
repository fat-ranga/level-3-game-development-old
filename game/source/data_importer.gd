extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_json_data(path: String):
	var data_file = FileAccess.open(path, FileAccess.READ)
	var json_data = JSON.parse_string(data_file.get_as_text())

	print(json_data)
	
	print(json_data.block_types.air.is_solid)
	return json_data
#	var error = json.parse(json_string)
#	if error == OK:
#		var data_received = json.data
#		if typeof(data_received) == TYPE_ARRAY:
#			print(data_received) # Prints array
#		else:
#			print("Unexpected data")
#	else:
#		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	
