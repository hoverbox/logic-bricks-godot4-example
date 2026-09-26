extends Area3D

# === LOGIC BRICKS START ===

func _ready() -> void:
	_logic_brick_init_states()

var _logic_brick_state: String = ""

func _logic_brick_init_states() -> void:
	_logic_brick_state = "state_1"

func _logic_brick_chain_state_matches(state_id: String, all_states: bool = false) -> bool:
	if all_states:
		return true
	if state_id.is_empty():
		return true
	return _logic_brick_state == state_id

func _logic_brick_get_state_signature() -> String:
	return _logic_brick_state

func _logic_brick_set_state(new_state: String) -> void:
	if _logic_brick_state == new_state:
		return
	_logic_brick_state = new_state
	_on_logic_brick_state_enter(new_state)

func _on_logic_brick_state_enter(state_id: String) -> void:
	pass

func _process(delta: float) -> void:
	_logic_brick__18(delta)

func _logic_brick__18(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var sensor_0_active = false
	sensor_0_active = true
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		if not (self is Node3D):
			push_warning("Rotation Actuator: self is not a Node3D")
		else:
			self.rotate_y(deg_to_rad(5))
# === LOGIC BRICKS END ===
