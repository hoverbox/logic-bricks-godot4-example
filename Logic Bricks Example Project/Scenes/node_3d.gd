extends Node3D

# === LOGIC BRICKS START ===
# Logic brick state (1-30)
var _logic_brick_state: int = 1

func _process(delta: float) -> void:
	match _logic_brick_state:
		1:
			_logic_brick__18(delta)

func _logic_brick__18(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = true
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		rotate_x(deg_to_rad(3.00))
# === LOGIC BRICKS END ===
