extends Node

const server_port = 3636

var room_creation_path = "res://assets/ui/demo/room_creation.tscn"
var main_room_path = "res://assets/maps/Map_demo.tscn"

var created_room_id
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

func change_scene_deferred(path):
	var scene_name = get_tree().current_scene.name
	var node_scene = get_tree().root.get_node(str(scene_name))
	get_tree().root.remove_child(node_scene)
	node_scene.call_deferred("free")

	var next_level_resource = load(path)
	var next_level = next_level_resource.instantiate()
	get_tree().root.add_child(next_level)
