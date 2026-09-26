extends StaticBody3D

# === LOGIC BRICKS START ===
var _wp_idx__24_0: int = 0
var _wp_prev_idx__24_0: int = -1
var _wp_dir__24_0: int = 1
var _wp_done__24_0: bool = false
var _wp_points__24_0: Array = []

func _wp_init_points__24_0() -> void:
	_wp_points__24_0 = [Vector3(0.000, 0.000, 0.000), Vector3(0.000, 0.000, 0.000), Vector3(0.000, 0.000, 0.000)].duplicate()
	for _wp_i in range(_wp_points__24_0.size()):
		var _wp_child = get_node_or_null("pos_%d" % _wp_i)
		if _wp_child is Node3D:
			_wp_points__24_0[_wp_i] = _wp_child.global_position


func _ready() -> void:
	_logic_brick_init_states()
	_wp_init_points__24_0()

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
	if state_id == "state_1":
		_wp_idx__24_0 = 0
		_wp_prev_idx__24_0 = -1
		_wp_dir__24_0 = 1
		_wp_done__24_0 = false
		_wp_points__24_0 = []

func _physics_process(delta: float) -> void:
	_logic_brick__24(delta)

func _logic_brick__24(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var sensor_0_active = false
	sensor_0_active = true
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		if _wp_points__24_0.is_empty():
			_wp_init_points__24_0()
			if _wp_points__24_0.is_empty():
				return
		_wp_idx__24_0 = clampi(_wp_idx__24_0, 0, _wp_points__24_0.size() - 1)
		var _wp_target__24_0: Vector3 = _wp_points__24_0[_wp_idx__24_0]
		var _wp_dist__24_0 = global_position.distance_to(_wp_target__24_0)
		var _wp_move_dir__24_0 = (_wp_target__24_0 - global_position).normalized()
		var _wp_self__24_0: Variant = self
		var _wp_speed__24_0 = float(1.000)
		var _wp_arrival_distance__24_0 = float(0.500)
		if _wp_dist__24_0 > _wp_arrival_distance__24_0:
			if _wp_self__24_0 is CharacterBody3D:
				(_wp_self__24_0 as CharacterBody3D).velocity.x = _wp_move_dir__24_0.x * _wp_speed__24_0
				(_wp_self__24_0 as CharacterBody3D).velocity.z = _wp_move_dir__24_0.z * _wp_speed__24_0
				(_wp_self__24_0 as CharacterBody3D).move_and_slide()
			else:
				global_position += _wp_move_dir__24_0 * _wp_speed__24_0 * _delta
		else:
			_wp_idx__24_0 = (_wp_idx__24_0 + 1) % _wp_points__24_0.size()
# === LOGIC BRICKS END ===
