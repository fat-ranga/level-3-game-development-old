extends Control

signal open_world

@onready var title = $Title
@onready var start_menu = $StartMenu
@onready var multiplayer_menu = $MultiplayerMenu
@onready var singleplayer_menu = $SingleplayerMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("StartMenu/Singleplayer").grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_singleplayer_pressed() -> void:
	start_menu.hide()
	title.hide()
	singleplayer_menu.show()


func _on_multiplayer_pressed() -> void:
	start_menu.hide()
	title.hide()
	multiplayer_menu.show()


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_exit_pressed() -> void:
	pass # Replace with function body.
