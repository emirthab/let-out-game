extends	Control

var selected_room_id : int

func _ready():
	bring_rooms()

func _on_create_room_pressed():
	$ItemList/room_creation.show()
	$ItemList/create_room.set_disabled(true)

func _on_close_room_creation_pressed():
	$ItemList/room_creation.hide()
	$ItemList/create_room.set_disabled(false)
	$ItemList/room_creation/Panel/name_input.text = ""
	$ItemList/room_creation/Panel/max_input.select(0)
	$ItemList/room_creation/Panel/pass_input.text = ""

#Room Create
func _on_ok_button_pressed():
	var	room_name =	$ItemList/room_creation/Panel/name_input.text
	var max_user = str2var($ItemList/room_creation/Panel/max_input.text) as int
	var	room_pass =	$ItemList/room_creation/Panel/pass_input.text

	if len(room_name) >	7 :
		if room_pass != "":
			if len(room_pass) >	3:
				var err = Server.create_server(GlobalConfigs.server_port,max_user)
				if err == OK:
					print("deneme0")
					Ngrok.start_ngrok(GlobalConfigs.server_port)
					var public_url = await Ngrok.get_public()
					print("deneme1")
					Firebase.create_room(room_name,room_pass,max_user,public_url["ip"],public_url["port"])
					print("deneme2")
			else:
				$error_panel/Timer.start()
				$error_panel.show()
				$error_panel/Label.text = "Room password must be higher than 3 character."
		else:
			var err = Server.create_server(GlobalConfigs.server_port,max_user)
			if err == OK:
				Ngrok.start_ngrok(GlobalConfigs.server_port)
				var public_url = await Ngrok.get_public()
				Firebase.create_room(room_name,room_pass,max_user,public_url["ip"],public_url["port"])
	else:
		$error_panel/Timer.start()
		$error_panel.show()
		$error_panel/Label.text = "Room name must be higher than 8 character."

func bring_rooms():
	GlobalConfigs.room_structure.clear()
	var rooms = await Firebase.get_rooms()
	if rooms != null:
		var lock_icon = load("res://assets/textures/icons/lock.png")
		for i in len(rooms):
			var room = rooms[i]
			if room != null:
				var user_data = str(room["users"])+"/"+str(room["max_users"])
				var room_name = room["name"]
				var total_char = 53 - len(room_name) - len(user_data)
				var spaces = ""
				for i in range(total_char):
					spaces = spaces+" "
				if room["pass"] == true:
					$ItemList.add_item("  "+ room_name + spaces + user_data,lock_icon)
				else:
					$ItemList.add_item("    "+ room_name + spaces + user_data)
				GlobalConfigs.room_structure.append(i)
				

func _on_timer_timeout():
	$error_panel.hide()

func _on_refresh_pressed():
	$ItemList.clear()
	$ItemList.add_item("    Room Name                                        Users")
	$ItemList.set_item_disabled(0,true)
	bring_rooms()

func _on_join_room_pressed():
	join_room()

func _on_item_list_item_activated(index):
	join_room()

func join_room():
	var selected = $ItemList.get_selected_items()
	if len(selected) > 0:
		selected_room_id = GlobalConfigs.room_structure[selected[0]-1]
		var room = Firebase.rooms[selected_room_id]
		if room["pass"] == false:
			var ip = room["ip"]
			var port = room["port"]
			Client.create_client(ip,port)	
		else:
			$ItemList/password_container.show()

func _on_close_password_pressed():
	$ItemList/password_container.hide()
	$ItemList/password_container/password_input.text = ""

func _on_ok_password_pressed():
	var password = $ItemList/password_container/password_input.text
	var meta = await Firebase.get_secret_room_meta(selected_room_id,password)
	if meta != null:
		var ip = meta["ip"]
		var port = meta["port"]
		Client.create_client(ip,port)