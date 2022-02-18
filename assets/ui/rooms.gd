@tool
extends	Control

var selected_room_id : int
var process_time : float = 0.0
var process_out : float = 0.05

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
				var err = Server.create_server(Globals.server_port,max_user)
				if err == OK:
					print("deneme0")
					Ngrok.start_ngrok(Globals.server_port)
					var public_url = await Ngrok.get_public()					
					Firebase.create_room(room_name,room_pass,max_user,public_url["ip"],public_url["port"])					
			else:
				$error_panel/Timer.start()
				$error_panel.show()
				$error_panel/Label.text = "Room password must be higher than 3 character."
		else:
			var err = Server.create_server(Globals.server_port,max_user)
			if err == OK:
				Ngrok.start_ngrok(Globals.server_port)
				var public_url = await Ngrok.get_public()
				Firebase.create_room(room_name,room_pass,max_user,public_url["ip"],public_url["port"])
	else:
		$error_panel/Timer.start()
		$error_panel.show()
		$error_panel/Label.text = "Room name must be higher than 8 character."

func bring_rooms():
	Globals.room_structure.clear()
	var rooms = await Firebase.get_rooms()
	if rooms != null:
		var lock_icon = load("res://assets/textures/icons/lock.png")
		for i in len(rooms):
			var room = rooms[i]
			if room != null:
				var user_data = str(room["users"])+"/"+str(room["max_users"])
				var room_name = room["name"]				
				if room["pass"] == true:
					$ItemList.add_item("  "+ room_name + " " + user_data,lock_icon)
				else:
					$ItemList.add_item("    "+ room_name + " " + user_data)
				Globals.room_structure.append(i)
				

func _on_timer_timeout():
	$error_panel.hide()

func _process(delta):
	process_time += delta
	if process_time >= process_out:
		
		#one char has : 9px width if font_size = 14
		var _rect_size = $ItemList.rect_size.x as int

		for _idx in range($ItemList.get_item_count()):
			var total_char = 0
			var room_name = ""
			var room_count = ""
			var _text = $ItemList.get_item_text(_idx)
			var _splitted = _text.split(" ") as Array
			for i in range(len(_splitted)):
				_splitted.erase("")

			for i in range(len(_splitted)):
				total_char += _splitted[i].length()
				if i != len(_splitted)-1:
					room_name += _splitted[i]+" "
				else:
					room_count += _splitted[i]
			
			#9 for 14px
			var total_lenght = (total_char * 9) + (len(_splitted) * 9)
			var space_count = ((_rect_size - total_lenght -55) / 9) as int
			print("char = "+str(total_char))
			print("space = "+str(space_count))
			print("name = "+str(room_name))
			print("count = "+str(room_count))

			var spaces = ""
			for i in range(space_count):
				spaces += " "
			
			$ItemList.set_item_text(_idx,"    " + room_name + spaces + room_count)
			
		process_time = 0

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
		selected_room_id = Globals.room_structure[selected[0]-1]
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
