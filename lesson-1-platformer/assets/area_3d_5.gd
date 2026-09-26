extends Area3D

# === LOGIC BRICKS START ===
var _col_area__26_sensor_0: Area3D = null

func _lb_find_node_by_name_recursive(node: Node, target_name: String) -> Node:
	if node == null or target_name.is_empty():
		return null
	if node.name == target_name:
		return node
	for child in node.get_children():
		var found = _lb_find_node_by_name_recursive(child, target_name)
		if found:
			return found
	return null

func _lb_find_collision_area_for_sensor(owner_node: Node, target_name: String) -> Area3D:
	if target_name.is_empty():
		return owner_node as Area3D
	if owner_node is Area3D and owner_node.name == target_name:
		return owner_node as Area3D
	var found = _lb_find_node_by_name_recursive(owner_node, target_name)
	if found is Area3D:
		return found as Area3D
	var owner_root = owner_node.get_owner() if is_instance_valid(owner_node) else null
	if owner_root and owner_root != owner_node:
		found = _lb_find_node_by_name_recursive(owner_root, target_name)
		if found is Area3D:
			return found as Area3D
	var scene_root = get_tree().current_scene
	if scene_root and scene_root != owner_root and scene_root != owner_node:
		found = _lb_find_node_by_name_recursive(scene_root, target_name)
		if found is Area3D:
			return found as Area3D
	found = _lb_find_node_by_name_recursive(get_tree().root, target_name)
	return found as Area3D
var _collision_entered__26_sensor_0: bool = false
var _collided_with__26_sensor_0 = null
func _on_collision__26_sensor_0_entered_body(body) -> void:
	_collision_entered__26_sensor_0 = true
	_collided_with__26_sensor_0 = body

func _on_collision__26_sensor_0_entered_area(area) -> void:
	_collision_entered__26_sensor_0 = true
	_collided_with__26_sensor_0 = area

func _setup_collision_sensor__26_sensor_0() -> void:
	# Collision Sensor (_26_sensor_0): locate Area3D by name, preferring this instance
	_col_area__26_sensor_0 = _lb_find_collision_area_for_sensor(self, "")
	if not _col_area__26_sensor_0:
		push_warning("Collision Sensor [_col_area__26_sensor_0]: could not find Area3D named '' anywhere in the scene")
	if _col_area__26_sensor_0:
		if not _col_area__26_sensor_0.body_entered.is_connected(_on_collision__26_sensor_0_entered_body):
			_col_area__26_sensor_0.body_entered.connect(_on_collision__26_sensor_0_entered_body)
		if not _col_area__26_sensor_0.area_entered.is_connected(_on_collision__26_sensor_0_entered_area):
			_col_area__26_sensor_0.area_entered.connect(_on_collision__26_sensor_0_entered_area)


func _ready() -> void:
	_logic_brick_init_states()
	_setup_collision_sensor__26_sensor_0()

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
		_col_area__26_sensor_0 = null
		_collision_entered__26_sensor_0 = false
		_collided_with__26_sensor_0 = null
		_setup_collision_sensor__26_sensor_0()

func _process(delta: float) -> void:
	_logic_brick__23(delta)
	_logic_brick__26(delta)

func _logic_brick__23(_delta: float) -> void:
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

func _logic_brick__26(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var sensor_0_active = false
	sensor_0_active = (func():
		if not _collision_entered__26_sensor_0:
			return false
		_collision_entered__26_sensor_0 = false
		return true
	).call()
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		get_tree().create_timer(0.10).timeout.connect(func():
			await get_tree().physics_frame
			if is_instance_valid(self):
				queue_free())
# === LOGIC BRICKS END ===
