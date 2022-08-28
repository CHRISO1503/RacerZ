extends Spatial

var restRotation

func _ready():
	restRotation = rotation

func _physics_process(delta):
	# This is in radians for some reason
	rotation = lerp(rotation, restRotation + Input.get_axis("right", "left") * Vector3(0 , 0.4, 0), delta * 3)
