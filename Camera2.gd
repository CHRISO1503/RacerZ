extends Camera


# Declare member variables here. Examples:
onready var camTarget = $"../car/camTarget"
var camZoom
var targetOffset

# Called when the node enters the scene tree for the first time.
func _ready():
	camZoom = 1.5
	#targetOffset = (global_translation - camTarget.global_translation).normalized() * camZoom
	targetOffset = Vector3(0, 0.12, 4) * camZoom

func _physics_process(delta):
	# Look to move offset to be relative to camTarget's local axes
	var currentTarget = camTarget.global_transform.translated(targetOffset)
	transform = transform.interpolate_with(currentTarget, delta * 10)
	
