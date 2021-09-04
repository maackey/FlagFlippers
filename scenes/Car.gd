extends Spatial

onready var body = $CarBody
const turn_speed = 8
const acceleration_forward = 15
const acceleration_sideways = 10
const flip_force = 20

func _physics_process(delta: float) -> void:
	var rot_input = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
	var z_input = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var x_input = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	var flipped = body.global_transform.basis.y.dot(Vector3.UP)
	
	if flipped < -0.5:
		body.add_torque(body.transform.basis.z * flip_force * flipped)
		
	body.add_torque(Vector3.UP * turn_speed * rot_input)
	body.add_force(body.global_transform.basis.xform(Vector3.FORWARD * acceleration_forward * z_input), Vector3.ZERO)
	body.add_force(body.global_transform.basis.xform(Vector3.LEFT * acceleration_sideways * x_input), Vector3.ZERO)
