extends Sprite3D

func set_name(name):
	$SubViewport/Label.text = name
	
func _process(delta):
	$SubViewport.size = $SubViewport/Label.rect_size
