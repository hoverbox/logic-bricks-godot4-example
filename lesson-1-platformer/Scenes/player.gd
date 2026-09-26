extends CharacterBody3D

# === LOGIC BRICKS START ===
var _logic_brick_character_use_acceleration: bool = false
var _logic_brick_character_acceleration: float = 1.0
var _logic_brick_character_motion_frame_prepared: bool = false
var _logic_brick_character_motion_active: bool = false
var _logic_brick_character_target_velocity: Vector3 = Vector3.ZERO
var _on_ground: bool = false
var _moving_platform_delta: Vector3 = Vector3.ZERO
var _moving_platform_velocity: Vector3 = Vector3.ZERO
var _inherited_platform_velocity: Vector3 = Vector3.ZERO
var _logic_brick_external_motion_delta: Vector3 = Vector3.ZERO
var _logic_brick_external_motion_total: Vector3 = Vector3.ZERO
var _logic_brick_pre_slide_velocity: Vector3 = Vector3.ZERO
var _jumps_remaining: int = 0
var _max_jumps: int = 0


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
	
	_logic_brick__9(delta)
	_logic_brick__12(delta)
	
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

func _logic_brick__9(_delta: float) -> void:
	if not _logic_brick_chain_state_matches("state_1", false):
		return
	
	# Sensor and controller input evaluation
	var sensor_0_active = false
	sensor_0_active = Input.is_action_pressed("right")
	
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
				var _motion_dir__9_0 = self.global_transform.basis * Vector3(5.000, 0.000, 0.000)
				if _logic_brick_character_use_acceleration:
					_logic_brick_character_target_velocity.x += _motion_dir__9_0.x
					_logic_brick_character_target_velocity.z += _motion_dir__9_0.z
					var _logic_brick_character_hvel_motion__9_0_2147876993__9_0 = Vector2(_logic_brick_character_target_velocity.x, _logic_brick_character_target_velocity.z)
					var _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0 = maxf(absf(_logic_brick_character_hvel_motion__9_0_2147876993__9_0.x), absf(_logic_brick_character_hvel_motion__9_0_2147876993__9_0.y))
					if _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0 > 0.0 and _logic_brick_character_hvel_motion__9_0_2147876993__9_0.length() > _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0:
						_logic_brick_character_hvel_motion__9_0_2147876993__9_0 = _logic_brick_character_hvel_motion__9_0_2147876993__9_0.normalized() * _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0
						_logic_brick_character_target_velocity.x = _logic_brick_character_hvel_motion__9_0_2147876993__9_0.x
						_logic_brick_character_target_velocity.z = _logic_brick_character_hvel_motion__9_0_2147876993__9_0.y
				else:
					self.velocity.x += _motion_dir__9_0.x
					self.velocity.z += _motion_dir__9_0.z
					var _logic_brick_character_hvel_motion__9_0_2147876993__9_0 = Vector2(self.velocity.x, self.velocity.z)
					var _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0 = maxf(absf(_logic_brick_character_hvel_motion__9_0_2147876993__9_0.x), absf(_logic_brick_character_hvel_motion__9_0_2147876993__9_0.y))
					if _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0 > 0.0 and _logic_brick_character_hvel_motion__9_0_2147876993__9_0.length() > _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0:
						_logic_brick_character_hvel_motion__9_0_2147876993__9_0 = _logic_brick_character_hvel_motion__9_0_2147876993__9_0.normalized() * _logic_brick_character_max_axis_speed_motion__9_0_2147876993__9_0
						self.velocity.x = _logic_brick_character_hvel_motion__9_0_2147876993__9_0.x
						self.velocity.z = _logic_brick_character_hvel_motion__9_0_2147876993__9_0.y
				# velocity.y intentionally preserved (gravity/jump from Character Actuator)

func _logic_brick__12(_delta: float) -> void:
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
		# No platform group configured; using normal CharacterBody3D floor behavior
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
# === LOGIC BRICKS END ===
