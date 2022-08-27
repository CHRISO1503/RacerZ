extends Spatial

func _process(_delta):
	if Input.is_action_just_pressed("headlights"):
		visible = not visible
