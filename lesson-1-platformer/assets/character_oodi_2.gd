extends CharacterBody3D

# === LOGIC BRICKS START ===
var _on_ground: bool = false
var _moving_platform_delta: Vector3 = Vector3.ZERO
var _moving_platform_velocity: Vector3 = Vector3.ZERO
var _moving_platform_last_positions: Dictionary = {}
var _moving_platform_current_id: int = 0
var _moving_platform_current_node: Node3D = null
var _inherited_platform_velocity: Vector3 = Vector3.ZERO
var _logic_brick_external_motion_delta: Vector3 = Vector3.ZERO
var _logic_brick_external_motion_total: Vector3 = Vector3.ZERO
var _logic_brick_pre_slide_velocity: Vector3 = Vector3.ZERO
var _logic_brick_character_use_acceleration: bool = false
var _logic_brick_character_acceleration: float = 1.0
var _logic_brick_character_motion_frame_prepared: bool = false
var _logic_brick_character_motion_active: bool = false
var _logic_brick_character_target_velocity: Vector3 = Vector3.ZERO
var _jumps_remaining: int = 0
var _max_jumps: int = 0
var _col_area__41_sensor_0: Area3D = null

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
var _collision_entered__41_sensor_0: bool = false
var _collided_with__41_sensor_0 = null
func _on_collision__41_sensor_0_entered_body(body) -> void:
	_collision_entered__41_sensor_0 = true
	_collided_with__41_sensor_0 = body

func _on_collision__41_sensor_0_entered_area(area) -> void:
	_collision_entered__41_sensor_0 = true
	_collided_with__41_sensor_0 = area

func _setup_collision_sensor__41_sensor_0() -> void:
	# Collision Sensor (_41_sensor_0): locate Area3D by name, preferring this instance
	_col_area__41_sensor_0 = _lb_find_collision_area_for_sensor(self, "enemy_head")
	if not _col_area__41_sensor_0:
		push_warning("Collision Sensor [_col_area__41_sensor_0]: could not find Area3D named 'enemy_head' anywhere in the scene")
	if _col_area__41_sensor_0:
		if not _col_area__41_sensor_0.body_entered.is_connected(_on_collision__41_sensor_0_entered_body):
			_col_area__41_sensor_0.body_entered.connect(_on_collision__41_sensor_0_entered_body)
		if not _col_area__41_sensor_0.area_entered.is_connected(_on_collision__41_sensor_0_entered_area):
			_col_area__41_sensor_0.area_entered.connect(_on_collision__41_sensor_0_entered_area)


func _ready() -> void:
	_logic_brick_init_states()
	_setup_collision_sensor__41_sensor_0()

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
		_col_area__41_sensor_0 = null
		_collision_entered__41_sensor_0 = false
		_collided_with__41_sensor_0 = null
		_setup_collision_sensor__41_sensor_0()

func _process(delta: float) -> void:
	_logic_brick__28(delta)
	_logic_brick__31(delta)
	_logic_brick__34(delta)
	_logic_brick__36(delta)
	_logic_brick__41(delta)

func _physics_process(delta: float) -> void:
	# Character motion state
	_logic_brick_character_use_acceleration = false
	_logic_brick_character_acceleration = clampf(float(1.000), 0.0, 1.0)
	_logic_brick_character_motion_frame_prepared = false
	_logic_brick_character_motion_active = false
	_logic_brick_character_target_velocity = Vector3.ZERO
	# Friction is normalized: 0 = no slowdown, 1 = quick stop
	var _logic_brick_friction = clampf(float(1.000), 0.0, 1.0)
	if _logic_brick_friction > 0.0:
		var _logic_brick_hvel = Vector2(velocity.x, velocity.z)
		var _logic_brick_friction_step = maxf(_logic_brick_hvel.length() * _logic_brick_friction * 12.0, _logic_brick_friction * 0.1) * delta
		_logic_brick_hvel = _logic_brick_hvel.move_toward(Vector2.ZERO, _logic_brick_friction_step)
		if _logic_brick_hvel.length() < 0.01:
			_logic_brick_hvel = Vector2.ZERO
		velocity.x = _logic_brick_hvel.x
		velocity.z = _logic_brick_hvel.y
	
	_logic_brick__25(delta)
	
	# Track externally-applied platform motion so look/movement sensors can ignore it next frame
	_logic_brick_external_motion_delta = Vector3.ZERO
	# Carry character with moving platform before applying player velocity
	if _on_ground and _moving_platform_delta != Vector3.ZERO:
		global_position += _moving_platform_delta
		_logic_brick_external_motion_delta += _moving_platform_delta
		_logic_brick_external_motion_total += _moving_platform_delta
	# Optional acceleration: ease toward the motion actuators' requested horizontal velocity
	if _logic_brick_character_use_acceleration and _logic_brick_character_motion_active:
		var _logic_brick_current_hvel = Vector2(velocity.x, velocity.z)
		var _logic_brick_target_hvel = Vector2(_logic_brick_character_target_velocity.x, _logic_brick_character_target_velocity.z)
		var _logic_brick_accel_step = maxf(absf(_logic_brick_target_hvel.x), absf(_logic_brick_target_hvel.y)) * _logic_brick_character_acceleration * 12.0 * delta
		_logic_brick_current_hvel = _logic_brick_current_hvel.move_toward(_logic_brick_target_hvel, _logic_brick_accel_step)
		velocity.x = _logic_brick_current_hvel.x
		velocity.z = _logic_brick_current_hvel.y
	# Add inherited platform momentum while airborne, after player speed normalization
	if not _on_ground and _inherited_platform_velocity != Vector3.ZERO:
		velocity.x += _inherited_platform_velocity.x
		velocity.z += _inherited_platform_velocity.z
		_logic_brick_external_motion_delta += _inherited_platform_velocity * delta
		_logic_brick_external_motion_total += _inherited_platform_velocity * delta
	# Move after all velocity changes are applied
	_logic_brick_pre_slide_velocity = velocity
	move_and_slide()
	# Optional character bounce. 0 = no bounce, 1 = full rebound.
	# Bounce is limited to real downward floor impacts so it does not steal normal jumps.
	var _logic_brick_bounce = clampf(float(0.000), 0.0, 1.0)
	if _logic_brick_bounce > 0.0 and _logic_brick_pre_slide_velocity.y < -0.08:
		for _logic_brick_col_i in range(get_slide_collision_count()):
			var _logic_brick_col := get_slide_collision(_logic_brick_col_i)
			if _logic_brick_col:
				var _logic_brick_normal = _logic_brick_col.get_normal()
				var _logic_brick_floor_hit = _logic_brick_normal.dot(up_direction) > cos(floor_max_angle)
				var _logic_brick_impact_speed = -_logic_brick_pre_slide_velocity.dot(_logic_brick_normal)
				if _logic_brick_floor_hit and _logic_brick_impact_speed > 0.08:
					var _logic_brick_rebound_y = _logic_brick_impact_speed * _logic_brick_bounce
					if _logic_brick_rebound_y < 0.12:
						velocity.y = 0.0
						_on_ground = true
						_jumps_remaining = _max_jumps
					else:
						velocity.y = _logic_brick_rebound_y
						_on_ground = false
					break

func _logic_brick__25(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var sensor_0_active = false
	sensor_0_active = true
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# CharacterBody3D grounding settings
		floor_snap_length = maxf(0.0, float(0.100))
		floor_max_angle = deg_to_rad(maxf(0.0, float(45.000)))
		# Ground detection
		_moving_platform_delta = Vector3.ZERO
		_moving_platform_velocity = Vector3.ZERO
		_on_ground = is_on_floor()
		# Moving platform support
		_moving_platform_delta = Vector3.ZERO
		_moving_platform_velocity = Vector3.ZERO
		var _matched_platform__25_0: Node3D = null
		var _found_floor_collision__25_0 := false
		if _on_ground:
			for _col_i in range(get_slide_collision_count()):
				var _test_col__25_0 := get_slide_collision(_col_i)
				if _test_col__25_0 and _test_col__25_0.get_normal().dot(up_direction) > cos(floor_max_angle):
					_found_floor_collision__25_0 = true
					var _platform_collider__25_0 = _test_col__25_0.get_collider()
					var _platform_search_node__25_0: Node = _platform_collider__25_0
					while _platform_search_node__25_0:
						if _platform_search_node__25_0.is_in_group("sticky"):
							if _platform_search_node__25_0 is Node3D:
								_matched_platform__25_0 = _platform_search_node__25_0
							break
						_platform_search_node__25_0 = _platform_search_node__25_0.get_parent()
					break
			# When walking, Godot may not keep a usable floor collision in the slide list every frame.
			# If no floor collision was reported but we are still on the floor, keep riding the same platform.
			if _matched_platform__25_0 == null and not _found_floor_collision__25_0 and _moving_platform_current_node != null:
				_matched_platform__25_0 = _moving_platform_current_node
		if _on_ground and _matched_platform__25_0:
			var _platform_id__25_0 = _matched_platform__25_0.get_instance_id()
			var _platform_pos__25_0 = _matched_platform__25_0.global_position
			if _moving_platform_current_id == _platform_id__25_0 and _moving_platform_last_positions.has(_platform_id__25_0):
				_moving_platform_delta = _platform_pos__25_0 - _moving_platform_last_positions[_platform_id__25_0]
				if _delta > 0.0:
					_moving_platform_velocity = _moving_platform_delta / _delta
			_moving_platform_last_positions[_platform_id__25_0] = _platform_pos__25_0
			_moving_platform_current_id = _platform_id__25_0
			_moving_platform_current_node = _matched_platform__25_0
		else:
			_moving_platform_current_id = 0
			_moving_platform_current_node = null
		# Gravity
		if _on_ground:
			_inherited_platform_velocity = Vector3.ZERO
			if velocity.y <= 0.0:
				_jumps_remaining = _max_jumps
			if velocity.y < 0.0:
				velocity.y = 0.0
		else:
			velocity.y -= (9.800) * _delta
			if velocity.y < -(50.000):
				velocity.y = -(50.000)

func _logic_brick__28(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var sensor_0_active = false
	sensor_0_active = false  # Input action not set
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		if not (self is Node3D):
			push_warning("Motion Actuator: self is not a Node3D")
		else:
			if not (self is CharacterBody3D):
				push_warning("Motion Actuator: Character Velocity requires the target node to be a CharacterBody3D")
			else:
				# Set CharacterBody3D velocity on active axes
				_logic_brick_character_motion_active = true
				if _logic_brick_character_use_acceleration:
					if not _logic_brick_character_motion_frame_prepared:
						_logic_brick_character_target_velocity = Vector3.ZERO
						_logic_brick_character_motion_frame_prepared = true
				else:
					if not _logic_brick_character_motion_frame_prepared:
						self.velocity.x = 0.0
						self.velocity.z = 0.0
						_logic_brick_character_motion_frame_prepared = true
				var _motion_dir__28_0 = self.global_transform.basis * Vector3(0.000, 0.000, 0.000)
				if _logic_brick_character_use_acceleration:
					_logic_brick_character_target_velocity.x += _motion_dir__28_0.x
					_logic_brick_character_target_velocity.z += _motion_dir__28_0.z
					var _logic_brick_character_hvel_position__28_0_3349694108__28_0 = Vector2(_logic_brick_character_target_velocity.x, _logic_brick_character_target_velocity.z)
					var _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0 = maxf(absf(_logic_brick_character_hvel_position__28_0_3349694108__28_0.x), absf(_logic_brick_character_hvel_position__28_0_3349694108__28_0.y))
					if _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0 > 0.0 and _logic_brick_character_hvel_position__28_0_3349694108__28_0.length() > _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0:
						_logic_brick_character_hvel_position__28_0_3349694108__28_0 = _logic_brick_character_hvel_position__28_0_3349694108__28_0.normalized() * _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0
						_logic_brick_character_target_velocity.x = _logic_brick_character_hvel_position__28_0_3349694108__28_0.x
						_logic_brick_character_target_velocity.z = _logic_brick_character_hvel_position__28_0_3349694108__28_0.y
				else:
					self.velocity.x += _motion_dir__28_0.x
					self.velocity.z += _motion_dir__28_0.z
					var _logic_brick_character_hvel_position__28_0_3349694108__28_0 = Vector2(self.velocity.x, self.velocity.z)
					var _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0 = maxf(absf(_logic_brick_character_hvel_position__28_0_3349694108__28_0.x), absf(_logic_brick_character_hvel_position__28_0_3349694108__28_0.y))
					if _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0 > 0.0 and _logic_brick_character_hvel_position__28_0_3349694108__28_0.length() > _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0:
						_logic_brick_character_hvel_position__28_0_3349694108__28_0 = _logic_brick_character_hvel_position__28_0_3349694108__28_0.normalized() * _logic_brick_character_max_axis_speed_position__28_0_3349694108__28_0
						self.velocity.x = _logic_brick_character_hvel_position__28_0_3349694108__28_0.x
						self.velocity.z = _logic_brick_character_hvel_position__28_0_3349694108__28_0.y
				# velocity.y intentionally preserved (gravity/jump from Character Actuator)

func _logic_brick__31(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var InputMap_001_sensor_0_active = false
	InputMap_001_sensor_0_active = false  # Input action not set
	
	# Controller logic
	var controller_active = InputMap_001_sensor_0_active
	
	# Actuator execution
	if controller_active:
		if not (self is Node3D):
			push_warning("Motion Actuator: self is not a Node3D")
		else:
			if not (self is CharacterBody3D):
				push_warning("Motion Actuator: Character Velocity requires the target node to be a CharacterBody3D")
			else:
				# Set CharacterBody3D velocity on active axes
				_logic_brick_character_motion_active = true
				if _logic_brick_character_use_acceleration:
					if not _logic_brick_character_motion_frame_prepared:
						_logic_brick_character_target_velocity = Vector3.ZERO
						_logic_brick_character_motion_frame_prepared = true
				else:
					if not _logic_brick_character_motion_frame_prepared:
						self.velocity.x = 0.0
						self.velocity.z = 0.0
						_logic_brick_character_motion_frame_prepared = true
				var _motion_dir__31_0 = self.global_transform.basis * Vector3(0.000, 0.000, 0.000)
				if _logic_brick_character_use_acceleration:
					_logic_brick_character_target_velocity.x += _motion_dir__31_0.x
					_logic_brick_character_target_velocity.z += _motion_dir__31_0.z
					var _logic_brick_character_hvel_position_001__31_0 = Vector2(_logic_brick_character_target_velocity.x, _logic_brick_character_target_velocity.z)
					var _logic_brick_character_max_axis_speed_position_001__31_0 = maxf(absf(_logic_brick_character_hvel_position_001__31_0.x), absf(_logic_brick_character_hvel_position_001__31_0.y))
					if _logic_brick_character_max_axis_speed_position_001__31_0 > 0.0 and _logic_brick_character_hvel_position_001__31_0.length() > _logic_brick_character_max_axis_speed_position_001__31_0:
						_logic_brick_character_hvel_position_001__31_0 = _logic_brick_character_hvel_position_001__31_0.normalized() * _logic_brick_character_max_axis_speed_position_001__31_0
						_logic_brick_character_target_velocity.x = _logic_brick_character_hvel_position_001__31_0.x
						_logic_brick_character_target_velocity.z = _logic_brick_character_hvel_position_001__31_0.y
				else:
					self.velocity.x += _motion_dir__31_0.x
					self.velocity.z += _motion_dir__31_0.z
					var _logic_brick_character_hvel_position_001__31_0 = Vector2(self.velocity.x, self.velocity.z)
					var _logic_brick_character_max_axis_speed_position_001__31_0 = maxf(absf(_logic_brick_character_hvel_position_001__31_0.x), absf(_logic_brick_character_hvel_position_001__31_0.y))
					if _logic_brick_character_max_axis_speed_position_001__31_0 > 0.0 and _logic_brick_character_hvel_position_001__31_0.length() > _logic_brick_character_max_axis_speed_position_001__31_0:
						_logic_brick_character_hvel_position_001__31_0 = _logic_brick_character_hvel_position_001__31_0.normalized() * _logic_brick_character_max_axis_speed_position_001__31_0
						self.velocity.x = _logic_brick_character_hvel_position_001__31_0.x
						self.velocity.z = _logic_brick_character_hvel_position_001__31_0.y
				# velocity.y intentionally preserved (gravity/jump from Character Actuator)

func _logic_brick__34(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var InputMap_002_sensor_0_active = false
	InputMap_002_sensor_0_active = false  # Input action not set
	
	# Controller logic
	var controller_active = InputMap_002_sensor_0_active
	
	# Actuator execution
	if controller_active:
		if not (self is Node3D):
			push_warning("Motion Actuator: self is not a Node3D")
		else:
			if not (self is CharacterBody3D):
				push_warning("Motion Actuator: Character Velocity requires the target node to be a CharacterBody3D")
			else:
				# Set CharacterBody3D velocity on active axes
				_logic_brick_character_motion_active = true
				if _logic_brick_character_use_acceleration:
					if not _logic_brick_character_motion_frame_prepared:
						_logic_brick_character_target_velocity = Vector3.ZERO
						_logic_brick_character_motion_frame_prepared = true
				else:
					if not _logic_brick_character_motion_frame_prepared:
						self.velocity.x = 0.0
						self.velocity.z = 0.0
						_logic_brick_character_motion_frame_prepared = true
				var _motion_dir__34_0 = self.global_transform.basis * Vector3(0.000, 0.000, 0.000)
				if _logic_brick_character_use_acceleration:
					_logic_brick_character_target_velocity.x += _motion_dir__34_0.x
					_logic_brick_character_target_velocity.z += _motion_dir__34_0.z
					var _logic_brick_character_hvel_position_002__34_0 = Vector2(_logic_brick_character_target_velocity.x, _logic_brick_character_target_velocity.z)
					var _logic_brick_character_max_axis_speed_position_002__34_0 = maxf(absf(_logic_brick_character_hvel_position_002__34_0.x), absf(_logic_brick_character_hvel_position_002__34_0.y))
					if _logic_brick_character_max_axis_speed_position_002__34_0 > 0.0 and _logic_brick_character_hvel_position_002__34_0.length() > _logic_brick_character_max_axis_speed_position_002__34_0:
						_logic_brick_character_hvel_position_002__34_0 = _logic_brick_character_hvel_position_002__34_0.normalized() * _logic_brick_character_max_axis_speed_position_002__34_0
						_logic_brick_character_target_velocity.x = _logic_brick_character_hvel_position_002__34_0.x
						_logic_brick_character_target_velocity.z = _logic_brick_character_hvel_position_002__34_0.y
				else:
					self.velocity.x += _motion_dir__34_0.x
					self.velocity.z += _motion_dir__34_0.z
					var _logic_brick_character_hvel_position_002__34_0 = Vector2(self.velocity.x, self.velocity.z)
					var _logic_brick_character_max_axis_speed_position_002__34_0 = maxf(absf(_logic_brick_character_hvel_position_002__34_0.x), absf(_logic_brick_character_hvel_position_002__34_0.y))
					if _logic_brick_character_max_axis_speed_position_002__34_0 > 0.0 and _logic_brick_character_hvel_position_002__34_0.length() > _logic_brick_character_max_axis_speed_position_002__34_0:
						_logic_brick_character_hvel_position_002__34_0 = _logic_brick_character_hvel_position_002__34_0.normalized() * _logic_brick_character_max_axis_speed_position_002__34_0
						self.velocity.x = _logic_brick_character_hvel_position_002__34_0.x
						self.velocity.z = _logic_brick_character_hvel_position_002__34_0.y
				# velocity.y intentionally preserved (gravity/jump from Character Actuator)

func _logic_brick__36(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var InputMap_003_sensor_0_active = false
	InputMap_003_sensor_0_active = false  # Input action not set
	
	# Controller logic
	var controller_active = InputMap_003_sensor_0_active
	
	# Actuator execution
	if controller_active:
		if not (self is Node3D):
			push_warning("Motion Actuator: self is not a Node3D")
		else:
			if not (self is CharacterBody3D):
				push_warning("Motion Actuator: Character Velocity requires the target node to be a CharacterBody3D")
			else:
				# Set CharacterBody3D velocity on active axes
				_logic_brick_character_motion_active = true
				if _logic_brick_character_use_acceleration:
					if not _logic_brick_character_motion_frame_prepared:
						_logic_brick_character_target_velocity = Vector3.ZERO
						_logic_brick_character_motion_frame_prepared = true
				else:
					if not _logic_brick_character_motion_frame_prepared:
						self.velocity.x = 0.0
						self.velocity.z = 0.0
						_logic_brick_character_motion_frame_prepared = true
				var _motion_dir__36_0 = self.global_transform.basis * Vector3(0.000, 0.000, 0.000)
				if _logic_brick_character_use_acceleration:
					_logic_brick_character_target_velocity.x += _motion_dir__36_0.x
					_logic_brick_character_target_velocity.z += _motion_dir__36_0.z
					var _logic_brick_character_hvel_position_003__36_0 = Vector2(_logic_brick_character_target_velocity.x, _logic_brick_character_target_velocity.z)
					var _logic_brick_character_max_axis_speed_position_003__36_0 = maxf(absf(_logic_brick_character_hvel_position_003__36_0.x), absf(_logic_brick_character_hvel_position_003__36_0.y))
					if _logic_brick_character_max_axis_speed_position_003__36_0 > 0.0 and _logic_brick_character_hvel_position_003__36_0.length() > _logic_brick_character_max_axis_speed_position_003__36_0:
						_logic_brick_character_hvel_position_003__36_0 = _logic_brick_character_hvel_position_003__36_0.normalized() * _logic_brick_character_max_axis_speed_position_003__36_0
						_logic_brick_character_target_velocity.x = _logic_brick_character_hvel_position_003__36_0.x
						_logic_brick_character_target_velocity.z = _logic_brick_character_hvel_position_003__36_0.y
				else:
					self.velocity.x += _motion_dir__36_0.x
					self.velocity.z += _motion_dir__36_0.z
					var _logic_brick_character_hvel_position_003__36_0 = Vector2(self.velocity.x, self.velocity.z)
					var _logic_brick_character_max_axis_speed_position_003__36_0 = maxf(absf(_logic_brick_character_hvel_position_003__36_0.x), absf(_logic_brick_character_hvel_position_003__36_0.y))
					if _logic_brick_character_max_axis_speed_position_003__36_0 > 0.0 and _logic_brick_character_hvel_position_003__36_0.length() > _logic_brick_character_max_axis_speed_position_003__36_0:
						_logic_brick_character_hvel_position_003__36_0 = _logic_brick_character_hvel_position_003__36_0.normalized() * _logic_brick_character_max_axis_speed_position_003__36_0
						self.velocity.x = _logic_brick_character_hvel_position_003__36_0.x
						self.velocity.z = _logic_brick_character_hvel_position_003__36_0.y
				# velocity.y intentionally preserved (gravity/jump from Character Actuator)

func _logic_brick__41(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var sensor_0_active = false
	sensor_0_active = (func():
		if not _collision_entered__41_sensor_0:
			return false
		if _collided_with__41_sensor_0:
			if _collided_with__41_sensor_0.name == "Player":
				_collision_entered__41_sensor_0 = false
				return true
		_collision_entered__41_sensor_0 = false  # Didn't match filter
		return false
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
