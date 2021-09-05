extends Spatial

onready var body = $CarBody
const turn_speed = 8
const acceleration_forward = 15
const acceleration_sideways = 10
const flip_force = 20

func _physics_process(delta: float) -> void:
	var rot_input = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	#Since the car faces toward -Z direction, forward is negative Z.
	var z_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	#Same goes for X axis.
	var x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var flipped = body.global_transform.basis.y.dot(Vector3.UP)
	
	if flipped < -0.5:
		#Use the cross product to correctly flip the car so that it stays upright.
		body.add_torque(body.global_transform.basis.y.cross(Vector3.UP).normalized() * flip_force * -flipped)
		
	body.add_torque(body.global_transform.basis.y * turn_speed * rot_input)
	body.add_force(body.global_transform.basis.z * acceleration_forward * z_input, Vector3.ZERO)
	body.add_force(body.global_transform.basis.x * acceleration_sideways * x_input, Vector3.ZERO)
