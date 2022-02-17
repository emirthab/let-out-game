extends Node

const path = "https://godot-demo-b2194-default-rtdb.europe-west1.firebasedatabase.app/"
var rooms = {}

func get_rooms():
	var resp = await HTTP.get_request(path+"rooms.json")
	if resp == "null":
		return null
	rooms = json_parser(resp)
	if str(rooms)[0] == "[":
		return rooms
	else:
		var array = []
		var offset = 0
		for room in rooms:
			var a = str2var(room) as int
			for i in range(offset,a+1):
				if i != a:
					array.append(null)
				else:
					array.append(rooms[room])
			offset = a
		rooms = array
		return rooms

func get_max_id_room():
	var data = await get_rooms()
	if data == null:
		return 0
	print(data)
	return len(data)

func create_room(room_name,room_pass,max_users,public_ip,public_port):
	var maxid = await get_max_id_room()
	var url = path+"rooms/"+str(maxid)+".json"
	var password = false if room_pass == "" else true
	var data = {
		"name": room_name,
		"max_users": max_users,
		"users": 1,
		"pass": password,
		"ip": public_ip,
		"port": public_port
	}
	data = var2str(data) as String
	print(data)
	if password:
		var url_meta = path+"room_metas/"+str(maxid)+".json"
		var data_meta = {
			room_pass:{
				"ip":public_ip,
				"port":public_port
			}
		}
		data_meta = var2str(data_meta) as String
		print(data_meta)
		HTTP.put_request(url_meta,data_meta)

	var resp = await HTTP.put_request(url,data)
	if resp[1] == 200:
		print("Room succesfully created")
		Ngrok.start_ngrok(GlobalConfigs.server_port)
		GlobalConfigs.created_room_id = maxid

func get_secret_room_meta(room_id,room_pass):
	var url = path + "room_metas/" + str(room_id) + "/" + room_pass + ".json"
	var req : String = await HTTP.get_request(url)
	if ("error") in req or req == "null":
		return null
	else:
		return json_parser(req)

func json_parser(data):
	var json = JSON.new()
	json.parse(data)
	return json.get_data()

func remove_room(room_id):
	var url = path+"rooms/"+str(room_id)+".json"
	OS.execute("curl",["-X","DELETE",url])
	HTTP.delete_request(url)

func get_user_count(room_id):
	var users = await HTTP.get_request(path+"rooms/"+str(room_id)+"/users.json")
	users = str2var(users) as int
	return users

func increase_user(room_id):
	var users = await get_user_count(room_id)
	var data = users+1
	data = var2str(data) as String
	HTTP.put_request(path+"rooms/"+str(room_id)+"/users.json",data)

func decrease_user(room_id):
	var users = await get_user_count(room_id)
	var data = users-1
	data = var2str(data) as String
	HTTP.put_request(path+"rooms/"+str(room_id)+"/users.json",data)
