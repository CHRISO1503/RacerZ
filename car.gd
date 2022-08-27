extends VehicleBody

var max_rpm = 3500.0
var max_torque = 1000.0
var brakeStrength = 30.0
var handbrakeStrength = 60.0
var frictionSlip = 4.5
var isBreaking = false
var steering_sensitivity = 0.13
var steering_responsiveness = 4.0

onready var last_pos = translation
var current_speed_mps
var current_gear = 1
var clutch_position : float = 1.0 # 0.0 = clutch engaged

var gear_shift_time = 0.3
var gear_timer = 0.0
var gear_sound_time = 8.0

export var max_engine_force = 700

export (Array) var gear_ratios = [3.827, 2.360, 1.685, 1.312, 1.0, 0.793]
export (float) var reverse_ratio = -2.5
export (float) var final_drive_ratio = 3.545
export (Curve) var power_curve = null

# Calculate the RPM of the engine based on the current velocity of the car
func calculate_rpm() -> float:
	if current_gear == 0:
		return 0.0
	var wheel_circumference : float = 2.0 * PI * $rear_right_wheel.wheel_radius
	var wheel_rotation_speed : float = 60.0 * current_speed_mps / wheel_circumference
	var drive_shaft_rotation_speed : float = wheel_rotation_speed * final_drive_ratio
	
	if current_gear == -1:
		return drive_shaft_rotation_speed * -reverse_ratio
	elif current_gear <= gear_ratios.size():
		return drive_shaft_rotation_speed * gear_ratios[current_gear - 1] 
	
	return 0.0

func _process_gear_inputs(delta : float):
	if gear_timer > 0.0:
		gear_timer = max(0.0, gear_timer - delta)
		clutch_position = 0.0
	else:
		if Input.is_action_just_pressed("shift_down") and current_gear > -1:
			current_gear = current_gear - 1
			gear_timer = gear_shift_time
			clutch_position = 0.0
		elif Input.is_action_just_pressed("shift_up") and current_gear < gear_ratios.size():
			current_gear = current_gear + 1
			gear_timer = gear_shift_time
			clutch_position = 0.0
		else:
			clutch_position = 1.0

# Processes-------------------------------------------------------------------------
func _process(delta):
	_process_gear_inputs(delta)
	
	# Create engine sounds
	var target_pitch = calculate_rpm() / 3500 + 1.5
	if current_gear > 0 and $engine_sound.playing == false:
		$engine_sound.play()
	elif $engine_sound.playing == true:
		$engine_sound.set_pitch_scale(target_pitch)
	if gear_timer > gear_shift_time * (1 - 1 / gear_sound_time):
		$engine_sound.pitch_scale *= 0.2 * cos((gear_shift_time - gear_timer) * 2 * PI / gear_shift_time * gear_sound_time) + 0.8

func _physics_process(delta):
	current_speed_mps = (translation - last_pos).length() / delta
	
	# Apply steering and engine force
	steering = lerp(steering, Input.get_axis("right", "left") * steering_sensitivity, steering_responsiveness * delta)
	var throttle_val = Input.get_action_strength("forward")
	var brakeInput = Input.get_action_strength("back")
	
	# Apply braking (isBreaking is used in $brakelights)
	if brakeInput > 0.1:
		isBreaking = true
	else:
		isBreaking = false
	if(Input.is_action_pressed("handbrake")):
		brake = handbrakeStrength
	else:
		brake = brakeInput * brakeStrength
	
	var rpm = calculate_rpm()
	var rpm_factor = clamp(rpm / max_rpm, 0.0, 1.0)
	var power_factor = power_curve.interpolate_baked(rpm_factor)
	
	if current_gear == -1:
		engine_force = clutch_position * throttle_val * power_factor * reverse_ratio * final_drive_ratio * max_engine_force
	elif current_gear > 0 and current_gear <= gear_ratios.size():
		engine_force = clutch_position * throttle_val * power_factor * gear_ratios[current_gear - 1] * final_drive_ratio * max_engine_force
	else:
		engine_force = 0
	
	last_pos = translation
