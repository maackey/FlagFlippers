extends Spatial

const turn_speed = 8
const acceleration_forward = 15
const acceleration_sideways = 10
const flip_force = 20
onready var body = $CarBody

remote var input: Vector3 = Vector3.ZERO
remote var remote_transform: Transform = transform

func _ready() -> void:
	#If one is a client
	if !get_tree().is_network_server():
		#Disable collision since the server will be simulating the collision
		$CarBody/CollisionShape.disabled = true
		$FL/CollisionShape.disabled = true
		$FR/CollisionShape.disabled = true
		$RL/CollisionShape.disabled = true
		$RR/CollisionShape.disabled = true

func _physics_process(delta: float) -> void:
	#If this is a master (one controls this node)
	if is_network_master():
		#If one is a server
		if get_tree().is_network_server():
			#Control the car directly
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
			#Tell the clients about your position, too.
			rset_unreliable("remote_transform",body.global_transform)
		else:
			#Send the input to the server....
			var rot_input = Input.get_action_strength("steer_left") - Input.get_action_strength("steer_right")
			#Since the car faces toward -Z direction, forward is negative Z.
			var z_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
			#Same goes for X axis.
			var x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			rset_unreliable_id(1,"input",Vector3(x_input,rot_input,z_input))
			#This car gets controlled by others.
			transform = remote_transform
	#Else this is a puppet (someone else controls this node)
	else:
		#If one is a server
		if get_tree().is_network_server():
			#Simulate the cars with the given input.
			var flipped = body.global_transform.basis.y.dot(Vector3.UP)

			if flipped < -0.5:
				#Use the cross product to correctly flip the car so that it stays upright.
				body.add_torque(body.global_transform.basis.y.cross(Vector3.UP).normalized() * flip_force * -flipped)
				
			body.add_torque(body.global_transform.basis.y * turn_speed * input.y)
			body.add_force(body.global_transform.basis.z * acceleration_forward * input.z, Vector3.ZERO)
			body.add_force(body.global_transform.basis.x * acceleration_sideways * input.x, Vector3.ZERO)
			rset_unreliable("remote_transform",body.global_transform)
		else:
			#This car gets controlled by others.
			transform = remote_transform

func setcurrent():
	$CarBody/Camera.current = true
