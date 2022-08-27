extends Camera


# Declare member variables here. Examples:
onready var camTarget = $"../car/camTarget"

var currentLook
var camZoom

# Called when the node enters the scene tree for the first time.
func _ready():
	currentLook = camTarget.translation
	camZoom = 8


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	var targetPos = camTarget.global_translation
	
	# Smooth look towards targetPos
	currentLook = lerp(currentLook, targetPos, delta * 20)
	look_at(currentLook, Vector3.UP)
	
	# Move towards targetPos
	var posTarget = targetPos + (translation - targetPos).normalized() * camZoom
	translation = lerp(translation, posTarget, delta * 5)
	
