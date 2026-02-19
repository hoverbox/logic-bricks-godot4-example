extends StaticBody3D

# === LOGIC BRICKS START ===
var _msg_received__5: bool = false
var _msg_subject__5: String = ""
var _msg_body__5: String = ""
var _msg_sender__5: Node = null

# Logic brick state (1-30)
var _logic_brick_state: int = 1

func _process(delta: float) -> void:
	match _logic_brick_state:
		1:
			_logic_brick__5(delta)

func _logic_brick__5(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = _msg_received__5
	# Reset flag after checking (one-shot)
	_msg_received__5 = false
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		get_tree().create_timer(0.10).timeout.connect(queue_free)
		print("received")
# === LOGIC BRICKS END ===
