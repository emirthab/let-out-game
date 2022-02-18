extends Sprite3D

func set_name(_name):
	$SubViewport/Label.text = _name
	
func _process(delta):
	$SubViewport.size = $SubViewport/Label.rect_size
