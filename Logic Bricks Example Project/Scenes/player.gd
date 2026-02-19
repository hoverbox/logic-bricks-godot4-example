extends CharacterBody3D

# === LOGIC BRICKS START ===
# Variables
var speed: float = 4
var stick_speed: float = 0
var coin: int:
	get: return GlobalVars.coin
	set(val): GlobalVars.coin = val

var _prev_pos__63: Vector3 = Vector3.ZERO
var _prev_pos__64: Vector3 = Vector3.ZERO
var _audio_player__64: AudioStreamPlayer = null
var _audio_last_play__64: float = 0.0
@export var _text_node__70: Node
var _msg_received__71: bool = false
var _msg_subject__71: String = ""
var _msg_body__71: String = ""
var _msg_sender__71: Node = null
var _audio_player__71: AudioStreamPlayer = null
var _delay__79_elapsed: float = 0.0
var _audio_player__79: AudioStreamPlayer = null
var _on_ground: bool = false
var _jumps_remaining: int = 1
var _max_jumps: int = 1
@export var _look_at_target__69: Node3D
var _look_at_last_pos__69: Vector3 = Vector3.INF
@export var _camera__69: Camera3D
var _camera_offset__69: Vector3 = Vector3.ZERO
var _camera_rot_offset__69: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Capture initial camera offset and rotation from target
	if _camera__69:
		_camera_offset__69 = _camera__69.global_position - global_position
		_camera_rot_offset__69 = _camera__69.global_rotation - global_rotation

# Logic brick state (1-30)
var _logic_brick_state: int = 1

func _process(delta: float) -> void:
	# Reset horizontal velocity (motion actuators re-apply when active)
	velocity.x = 0.0
	velocity.z = 0.0
	
	match _logic_brick_state:
		1:
			_logic_brick__63(delta)
			_logic_brick__64(delta)
			_logic_brick__66(delta)
			_logic_brick__67(delta)
			_logic_brick__70(delta)
			_logic_brick__71(delta)
			_logic_brick__79(delta)
			_logic_brick__69(delta)
			_logic_brick__88(delta)
			_logic_brick__91(delta)
	
	# Move after all velocity changes are applied
	move_and_slide()

func _logic_brick__63(_delta: float) -> void:
	# Sensor evaluation
	# Calculate velocity from position change
	var _ms_pos = global_position
	var _ms_dt = get_physics_process_delta_time() if is_inside_tree() else 0.016
	var _ms_vel = (_ms_pos - _prev_pos__63) / _ms_dt if _ms_dt > 0 else Vector3.ZERO
	_prev_pos__63 = _ms_pos
	var sensor_0_active = _ms_vel.x > 0.100 or _ms_vel.x < -0.100 or _ms_vel.y > 0.100 or _ms_vel.y < -0.100 or _ms_vel.z > 0.100 or _ms_vel.z < -0.100
	
	# Controller logic
	var controller_active = not (sensor_0_active)
	
	# Actuator execution
	if controller_active:
		# Get node containing AnimationPlayer
		var _anim_node = get_node_or_null("Guy")
		if _anim_node:
			# Find AnimationPlayer on the node
			var _anim_player: AnimationPlayer = null
			for child in _anim_node.get_children():
				if child is AnimationPlayer:
					_anim_player = child
					break
			if _anim_player:
				_anim_player.play("idle_001", 0.300, 1.000, false)
			else:
				push_warning("Animation Actuator: No AnimationPlayer found on node Guy")
		else:
			push_warning("Animation Actuator: Node not found at path Guy")

func _logic_brick__64(_delta: float) -> void:
	# Sensor evaluation
	# Calculate velocity from position change
	var _ms_pos = global_position
	var _ms_dt = get_physics_process_delta_time() if is_inside_tree() else 0.016
	var _ms_vel = (_ms_pos - _prev_pos__64) / _ms_dt if _ms_dt > 0 else Vector3.ZERO
	_prev_pos__64 = _ms_pos
	var sensor_0_active = _ms_vel.x > 0.000 or _ms_vel.x < -0.000 or _ms_vel.z > 0.000 or _ms_vel.z < -0.000
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Get node containing AnimationPlayer
		var _anim_node = get_node_or_null("Guy")
		if _anim_node:
			# Find AnimationPlayer on the node
			var _anim_player: AnimationPlayer = null
			for child in _anim_node.get_children():
				if child is AnimationPlayer:
					_anim_player = child
					break
			if _anim_player:
				_anim_player.play("ZombieWalk", 0.300, 1.000, false)
			else:
				push_warning("Animation Actuator: No AnimationPlayer found on node Guy")
		else:
			push_warning("Animation Actuator: Node not found at path Guy")
		# Check minimum delay between plays
		var _current_time = Time.get_ticks_msec() / 1000.0
		if _current_time - _audio_last_play__64 >= 0.400:
			_audio_last_play__64 = _current_time
			# Sound actuator - Play
			if _audio_player__64 == null:
				_audio_player__64 = AudioStreamPlayer.new()
				add_child(_audio_player__64)
				_audio_player__64.stream = load("res://Assets/sound/01-footstep.ogg")
			_audio_player__64.volume_db = 0.60
			_audio_player__64.pitch_scale = 1.00
			if not _audio_player__64.playing:
				_audio_player__64.play()

func _logic_brick__66(_delta: float) -> void:
	# Sensor evaluation
	var _axis_val = Input.get_axis("left", "right")
	stick_speed = _axis_val
	var left_right_active = absf(_axis_val) > 0.100
	
	# Controller logic
	var controller_active = left_right_active
	
	# Actuator execution
	if controller_active:
		# Set velocity on active axes
		var _motion_vel = global_transform.basis * Vector3(stick_speed*speed, 0.000, 0.000)
		velocity.x = _motion_vel.x

func _logic_brick__67(_delta: float) -> void:
	# Sensor evaluation
	var _axis_val = Input.get_axis("down", "up")
	stick_speed = _axis_val
	var up_down_active = absf(_axis_val) > 0.100
	
	# Controller logic
	var controller_active = up_down_active
	
	# Actuator execution
	if controller_active:
		# Set velocity on active axes
		var _motion_vel = global_transform.basis * Vector3(0.000, 0.000, stick_speed*-speed)
		velocity.z = _motion_vel.z

func _logic_brick__70(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = true
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Update text display
		if not _text_node__70:
			push_warning("Text Actuator: No text node assigned to '_text_node__70' — drag a Label, Label3D, or RichTextLabel into the inspector")
		else:
			# Display variable with optional prefix/suffix
			var _value = str(coin)
			var _display_text = "Coins:" + _value + "/5"
			if _text_node__70 is Label or _text_node__70 is Label3D:
				_text_node__70.text = _display_text
			elif _text_node__70 is RichTextLabel:
				_text_node__70.text = _display_text

func _logic_brick__71(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = _msg_received__71
	# Reset flag after checking (one-shot)
	_msg_received__71 = false
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		if "coin" in self:
			self.coin += 1
		else:
			self.coin = 1
		# Sound actuator - Play
		if _audio_player__71 == null:
			_audio_player__71 = AudioStreamPlayer.new()
			add_child(_audio_player__71)
			_audio_player__71.stream = load("res://Assets/sound/50-CC0-retro-synth-SFX/retro_coin_02.ogg")
		_audio_player__71.volume_db = 1.00
		_audio_player__71.pitch_scale = 1.00
		var _overlap = AudioStreamPlayer.new()
		add_child(_overlap)
		_overlap.stream = _audio_player__71.stream
		_overlap.volume_db = _audio_player__71.volume_db
		_overlap.pitch_scale = _audio_player__71.pitch_scale
		_overlap.finished.connect(_overlap.queue_free)
		_overlap.play()

func _logic_brick__79(_delta: float) -> void:
	# Sensor evaluation
	# Delay sensor
	_delay__79_elapsed += _delta
	var sensor_0_active = false
	if _delay__79_elapsed >= 0.00:
		sensor_0_active = true
		_delay__79_elapsed = 0.0  # Reset timer
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Sound actuator - Play
		if _audio_player__79 == null:
			_audio_player__79 = AudioStreamPlayer.new()
			add_child(_audio_player__79)
			_audio_player__79.stream = load("res://Assets/sound/theme.ogg")
		_audio_player__79.volume_db = 0.50
		_audio_player__79.pitch_scale = 1.00
		if not _audio_player__79.playing:
			_audio_player__79.play()

func _logic_brick__69(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = true
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Ground detection
		_on_ground = is_on_floor()
		# Gravity
		if _on_ground:
			if velocity.y <= 0.0:
				_jumps_remaining = _max_jumps
			if velocity.y < 0.0:
				velocity.y = 0.0
		else:
			velocity.y -= 9.800 * _delta
			if velocity.y < -50.000:
				velocity.y = -50.000
		# Jump
		if Input.is_action_just_pressed("jump"):
			if _jumps_remaining > 0:
				velocity.y = sqrt(2.0 * 9.800 * 1.000)
				_jumps_remaining -= 1
		# Rotate target node to face movement direction
		if not _look_at_target__69:
			push_warning("Look At Movement: No Node3D assigned to '_look_at_target__69' — drag one into the inspector")
		else:
			# Track position change for movement direction
			if _look_at_last_pos__69 == Vector3.INF:
				_look_at_last_pos__69 = global_position
			var _movement_dir = global_position - _look_at_last_pos__69
			_look_at_last_pos__69 = global_position
			# Flatten to horizontal plane
			_movement_dir.y = 0.0
			# Only rotate if actually moving
			if _movement_dir.length_squared() > 0.0001:
				var _look_target = global_position + _movement_dir.normalized()
				# Smooth rotation using look_at
				var _current_y = _look_at_target__69.global_rotation.y
				_look_at_target__69.look_at(_look_target, Vector3.UP)
				var _target_y = _look_at_target__69.global_rotation.y + PI
				_look_at_target__69.global_rotation.y = lerp_angle(_current_y, _target_y, 0.100000)
		# Smooth follow — camera tracks this object while maintaining offset
		if not _camera__69:
			push_warning("Camera Actuator: No Camera3D assigned to '_camera__69' — drag one into the inspector")
		else:
			var _cam_pos = _camera__69.global_position
			# Desired position = target + fixed offset
			var _desired_pos = global_position + _camera_offset__69
			var _diff = _desired_pos - _cam_pos
			# Smoothly interpolate position (maintaining offset)
			var _new_pos = _cam_pos
			_new_pos.x = lerp(_cam_pos.x, _desired_pos.x, 5.00 * _delta)
			_new_pos.y = lerp(_cam_pos.y, _desired_pos.y, 5.00 * _delta)
			_new_pos.z = lerp(_cam_pos.z, _desired_pos.z, 5.00 * _delta)
			_camera__69.global_position = _new_pos

func _logic_brick__88(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = Input.is_action_pressed("save")
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Save game state
		var _save_data: Dictionary = {}
		_save_data["position"] = {"x": global_position.x, "y": global_position.y, "z": global_position.z}
		_save_data["rotation"] = {"x": global_rotation.x, "y": global_rotation.y, "z": global_rotation.z}
		# Save all non-private script variables
		var _vars: Dictionary = {}
		for _prop in get_script().get_script_property_list():
			var _name = _prop["name"]
			if _name.begins_with("_") or _name.begins_with("@"):
				continue
			var _val = get(_name)
			if _val is int or _val is float or _val is bool or _val is String:
				_vars[_name] = _val
		_save_data["variables"] = _vars
		var _file = FileAccess.open("user://save_slot1.json", FileAccess.WRITE)
		if _file:
			_file.store_string(JSON.stringify(_save_data))
			_file.close()

func _logic_brick__91(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = Input.is_action_pressed("load")
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Load game state
		if FileAccess.file_exists("user://save_slot1.json"):
			var _file = FileAccess.open("user://save_slot1.json", FileAccess.READ)
			if _file:
				var _json = JSON.new()
				var _err = _json.parse(_file.get_as_text())
				_file.close()
				if _err == OK:
					var _save_data = _json.data
					if _save_data.has("position"):
						var _pos = _save_data["position"]
						global_position = Vector3(_pos["x"], _pos["y"], _pos["z"])
					if _save_data.has("rotation"):
						var _rot = _save_data["rotation"]
						global_rotation = Vector3(_rot["x"], _rot["y"], _rot["z"])
					if _save_data.has("variables"):
						for _name in _save_data["variables"]:
							set(_name, _save_data["variables"][_name])


# Message handler method (called by Message Actuator)
func _on_message_received(subject: String, body: String, sender: Node) -> void:
	if subject == "coin":
		_msg_received__71 = true
		_msg_subject__71 = subject
		_msg_body__71 = body
		_msg_sender__71 = sender
# === LOGIC BRICKS END ===
