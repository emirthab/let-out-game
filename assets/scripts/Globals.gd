extends Node

const server_port = 3636

const room_creation_path : String = "res://assets/ui/demo/room_creation.tscn"
const main_room_path : String = "res://assets/maps/Map_demo.tscn"

var created_room_id : int
var room_structure = []
var user_type = 0 #1 for server 2 for client

var user_name = "emirtaha"
var clients = {}

func _notification(what):
	if what == 1006:
		Firebase.remove_room(created_room_id)
		Ngrok.kill_ngrok()	
		get_tree().quit()
	if what == MainLoop.NOTIFICATION_CRASH:
		Firebase.remove_room(created_room_id)
		Ngrok.kill_ngrok()
		get_tree().quit()

func get_current_scene():
	return get_tree().current_scene

func _change_scene(path):
	get_tree().change_scene(path)
