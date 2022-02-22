extends Node

var server : WebSocketServer = Server.server
var client : WebSocketClient = Client.client

func _on_data_server(id):
	var pkt = server.get_peer(id).get_packet().get_string_from_utf8()
	pkt = str2var(pkt) as Array
	match pkt[0]:
		0x00:
			var _name = pkt[1]
			_on_player_connected(id,_name)
			Server.send_data_all_players_except_ids([id],[0x00,id,_name])
			#Firebase.increase_user(Globals.created_room_id)

			#other players info send to connected peer
			for client_id in Globals.clients:
				var _client = Globals.clients[client_id]
				var _data = [0x00,client_id,_client["name"]]
				Server.send_data_spesific_ids([id],_data)

func _on_data_client():
	var pkt = client.get_peer(1).get_packet().get_string_from_utf8()
	pkt = str2var(pkt) as Array
	match pkt[0]:
		0x00: _on_player_connected(pkt[1],pkt[2])
		0x01: _on_player_disconnected(pkt[1])
		0x02: _start_game() #todo game configs

#0x00 - remotesync
func _on_player_connected(id,_name):
	var scene = Globals.get_current_scene()
	scene.add_player_in_lobby(id,_name)
	Globals.clients[id] = {"name": _name}
	#Firebase.increase_user(Globals.created_room_id)
	
func _on_player_disconnected(id):
	var scene = Globals.get_current_scene()
	scene.remove_player_in_lobby(id)
	Globals.clients.erase(id)
	#Firebase.decrease_user(Globals.created_room_id)

func _start_game():
	Globals._change_scene(Globals.main_room_path)
	#Globals._change_scene("res://assets/maps/Map_demo.tscn")
