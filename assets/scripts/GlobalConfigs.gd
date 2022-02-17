extends Node

const server_port = 3636

var created_room_id
var room_structure = []
var user_type = 0 #1 for server 2 for client

func _notification(what):
	if what == 1006:
		Firebase.remove_room(created_room_id)
		Ngrok.kill_ngrok()	
		get_tree().quit()
	if what == MainLoop.NOTIFICATION_CRASH:
		Firebase.remove_room(created_room_id)
		Ngrok.kill_ngrok()
		get_tree().quit()
