extends Spatial


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$CarBody.add_torque(Vector3.UP*8*(Input.get_action_strength("steer_left")-Input.get_action_strength("steer_right")))
	$CarBody.add_force($CarBody.global_transform.basis.xform(Vector3.FORWARD*15*(Input.get_action_strength("move_forward")-Input.get_action_strength("move_backward"))),Vector3.ZERO)
	$CarBody.add_force($CarBody.global_transform.basis.xform(Vector3.LEFT*10*(Input.get_action_strength("move_left")-Input.get_action_strength("move_right"))),Vector3.ZERO)

func _input(e: InputEvent) -> void:
	pass
