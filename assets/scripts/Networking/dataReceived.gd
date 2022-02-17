extends Node

var server : WebSocketServer = Server.server
var client : WebSocketClient = Client.client

func _on_data_server(id):
	var pkt = server.get_peer(id).get_packet()
	print(pkt)

func _on_data_client(id):
	var pkt = client.get_peer(id).get_packet()
	print(pkt)
