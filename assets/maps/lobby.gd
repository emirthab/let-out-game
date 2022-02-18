extends	Node3D

func _ready():
	if Globals.user_type == 1:
		add_player_in_lobby(1,Globals.user_name)
		$start_button.show()

func add_player_in_lobby(id,player_name):
	var lobby_players_node : Node3D = get_node("Players")
	
	var pos_index : int
	for player_pos in lobby_players_node.get_children():
		if player_pos.get_child_count() == 0:
			var pos_name = player_pos.name
			var _pos_index = str(pos_name)[6]
			pos_index = str2var(_pos_index) as int
			break

	var	puppet_player =	preload("res://assets/player/puppet_player.tscn").instantiate()
	var	playerName = preload("res://assets/player/name/player_name.tscn").instantiate()
	playerName.set_name(player_name)

	puppet_player.name = str(id)

	var	pos	= get_node("Players/player"+str(pos_index)+"Pos")
	puppet_player.add_child(playerName)
	pos.add_child(puppet_player)

func remove_player_in_lobby(id):
	var lobby_players_node : Node3D = get_node("Players")
	for player_pos in lobby_players_node.get_children():
		if player_pos.get_child_count() != 0:
			var player = player_pos.get_child(0)
			if player.name == str(id) : player.queue_free()				

func _on_start_button_pressed():
	Server.send_data_all_players([0x02])
	Server.data_receiver._start_game()
