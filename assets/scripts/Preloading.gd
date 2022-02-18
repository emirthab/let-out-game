extends	Node
var	playerName = preload("res://assets/player/name/player_name.tscn").instantiate()

func _ready():
	playerName.connect("tree_entered",tree_entered)
	playerName.name	= "player_name_preload"
	playerName.set_name("player_name")
	add_child(playerName)

func tree_entered():
	playerName.queue_free()