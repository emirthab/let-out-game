extends Node

var server = WebSocketServer.new()

var max_user_room = 0
var players = {}

var data_received = load("res://assets/scripts/Networking/dataReceived.gd")

func create_server(port,max_user):
	server.connect("client_connected", _connected)
	server.connect("client_disconnected", _disconnected)
	server.connect("client_close_request", _close_request)
	server.connect("data_received",data_received.new()._on_data_server)

	var err = server.listen(port)
	if err == OK:
		print("server started at port : "+str(port))
		max_user_room = max_user
		players[0] = {
			"status":0
		}
		GlobalConfigs.user_type = 1
		get_tree().change_scene("res://assets/maps/lobby_scene.tscn")
		return OK
		
	else:
		print("Unable to start server")
		set_process(false)
		return false

func _connected(id, proto, resource_name):
	if len(players) <= max_user_room:
		players[id] = {
			"status":0
		}

		Firebase.increase_user(GlobalConfigs.created_room_id)
		print("Client %d connected with protocol: %s" % [id, proto])
	else:
		server.disconnect_peer(id)

func _disconnected(id, was_clean = false):
	players.erase(id)
	Firebase.decrease_user(GlobalConfigs.created_room_id)
	print("Client %d disconnected, clean: %s" % [id, str(was_clean)])

func _close_request(id, code, reason):
	players.erase(id)
	Firebase.decrease_user(GlobalConfigs.created_room_id)
	print("Client %d disconnecting with code: %d, reason: %s" % [id, code, reason])

func _process(delta):
	server.poll()
