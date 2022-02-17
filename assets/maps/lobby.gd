extends	Node3D

func _ready():
	if GlobalConfigs.user_type == 1:
		add_player_in_lobby("emirtaha",1)

func add_player_in_lobby(player_name,pos_id):
	var	puppet_player =	preload("res://assets/player/puppet_player.tscn").instantiate()
	var	playerName = preload("res://assets/player/name/player_name.tscn").instantiate()

	playerName.set_name("asetilen")

	var	pos	= get_node("Players/player"+str(pos_id)+"Pos")
	puppet_player.add_child(playerName)
	pos.add_child(puppet_player)

