extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var restRotation

# Called when the node enters the scene tree for the first time.
func _ready():
	restRotation = rotation


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# This is in radians for some reason
	rotation = lerp(rotation, restRotation + Input.get_axis("right", "left") * Vector3(0 , 0.4, 0), delta * 3)
