extends Node

var client = WebSocketClient.new()

var data_receiver

func _ready():
    data_receiver = load("res://assets/scripts/Networking/dataReceiver.gd").new()

func create_client(ip,port):
    client.connect("connection_closed", _closed)
    client.connect("connection_error", _closed)
    client.connect("connection_established", _connected)
    client.connect("data_received", data_receiver._on_data_client)

    var err
    if "ngrok" in ip:
        err = client.connect_to_url("tcp://" + ip + ":" +str(port))
    else:
        err = client.connect_to_url("ws://" + ip + ":" +str(port))
        
    if err != OK:      
        print("Unable to connect")
        set_process(false)

func _closed(was_clean = false):
    get_tree().change_scene(Globals.room_creation_path)
    Globals.clients.clear()
    print("Closed, clean: ", was_clean)
    set_process(false)

func _connected(proto = ""):
    get_tree().change_scene("res://assets/maps/lobby_scene.tscn")
    send_data([0x00,Globals.user_name])

    print("Connected with protocol: ", proto)

func _on_data():
    print("Got data from server: ", client.get_peer(1).get_packet().get_string_from_utf8())

func send_data(data):
    data = var2str(data) as String
    client.get_peer(1).put_packet(data.to_utf8_buffer())

func _process(delta):
    client.poll()