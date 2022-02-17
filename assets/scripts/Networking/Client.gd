extends Node

var client = WebSocketClient.new()

var data_received = load("res://assets/scripts/Networking/dataReceived.gd")

func create_client(ip,port):
    client.connect("connection_closed", _closed)
    client.connect("connection_error", _closed)
    client.connect("connection_established", _connected)
    client.connect("data_received", data_received.new()._on_data_client)

    var err
    if "ngrok" in ip:
        err = client.connect_to_url("tcp://" + ip + ":" +str(port))
    else:
        err = client.connect_to_url("ws://" + ip + ":" +str(port))
        
    if err != OK:
        print("Unable to connect")
        set_process(false)

func _closed(was_clean = false):
    print("Closed, clean: ", was_clean)
    set_process(false)

func _connected(proto = ""):
    print("Connected with protocol: ", proto)
    client.get_peer(1).put_packet("Test packet".to_utf8_buffer())

func _on_data():
    print("Got data from server: ", client.get_peer(1).get_packet().get_string_from_utf8())

func send_data(data):
    client.get_peer(1).put_packet("".to_utf8_buffer())

func _process(delta):
    client.poll()