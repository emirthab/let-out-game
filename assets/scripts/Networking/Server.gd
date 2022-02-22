extends	Node

var	server = WebSocketServer.new()

var	max_user_room =	0

var	data_receiver

func _ready():
	data_receiver =	load("res://assets/scripts/Networking/dataReceiver.gd").new()

func create_server(port,max_user):
	server.connect("client_connected", _connected)
	server.connect("client_disconnected", _disconnected)
	server.connect("client_close_request", _close_request)
	server.connect("data_received",data_receiver._on_data_server)

	var	err	= server.listen(port)
	if err == OK:
		print("server started at port :	"+str(port))
		max_user_room =	max_user

		Globals.clients[1] = {
			"name": Globals.user_name
		}

		Globals.user_type	= 1
		Globals._change_scene("res://assets/maps/lobby_scene.tscn")
		return OK
		
	else:
		print("Unable to start server")
		set_process(false)
		return false

func _connected(id,	proto, resource_name):
	if len(Globals.clients)	<= max_user_room:		
		print("Client %d connected with	protocol: %s" %	[id, proto])
	else:
		server.disconnect_peer(id)

func _disconnected(id, was_clean = false):
	data_receiver._on_player_disconnected(id)
	send_data_all_players([0x01,id])
	print("Client %d disconnected, clean: %s" %	[id, str(was_clean)])

func _close_request(id,	code, reason):
	data_receiver._on_player_disconnected(id)
	send_data_all_players([0x01,id])
	print("Client %d disconnecting with	code: %d, reason: %s" %	[id, code, reason])

func send_data_all_players(data):
	for	client_id in Globals.clients:
		if client_id != 1:
			data = var2str(data) as String
			server.get_peer(client_id).put_packet(str(data).to_utf8_buffer())

func send_data_all_players_except_ids(ids, data):
	for	client_id in Globals.clients:
		if client_id != 1 and !(client_id in ids):
			data = var2str(data) as String
			server.get_peer(client_id).put_packet(str(data).to_utf8_buffer())
		
func send_data_spesific_ids(ids, data):
	#for control : player is in clients
	for client_id in Globals.clients:
		if client_id in ids:
			data = var2str(data) as String
			server.get_peer(client_id).put_packet(str(data).to_utf8_buffer())

func _kick_player(id):
	server.disconnect_peer(id,1000,"You are kicked from host...")

func _process(delta):
	server.poll()
