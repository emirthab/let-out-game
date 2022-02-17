extends Control

func _ready():
	pass

func _on_client_pressed():
	Client.create_client("127.0.0.1",3636)

func _on_server_pressed():
	Server.create_server(3636,12)
