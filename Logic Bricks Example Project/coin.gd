extends Area3D

# === LOGIC BRICKS START ===
@export var _collision_area__25: Area3D
var _collision_entered__25: bool = false
var _collided_with__25 = null

func _on_collision__25_entered_body(body) -> void:
	_collision_entered__25 = true
	_collided_with__25 = body
func _on_collision__25_entered_area(area) -> void:
	_collided_with__25 = area

func _ready() -> void:
	# Connect collision signals for _collision_area__25
	if _collision_area__25:
		if not _collision_area__25.body_entered.is_connected(_on_collision__25_entered_body):
			_collision_area__25.body_entered.connect(_on_collision__25_entered_body)
		if not _collision_area__25.area_entered.is_connected(_on_collision__25_entered_area):
			_collision_area__25.area_entered.connect(_on_collision__25_entered_area)
	else:
		push_warning("Collision Sensor: No Area3D assigned to '_collision_area__25' — drag one into the inspector")

# Logic brick state (1-30)
var _logic_brick_state: int = 1

func _process(delta: float) -> void:
	match _logic_brick_state:
		1:
			_logic_brick__22(delta)
			_logic_brick__25(delta)

func _logic_brick__22(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = true
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		rotate_y(deg_to_rad(1.000))

func _logic_brick__25(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = (func():
		if not _collision_entered__25:
			return false
		if _collided_with__25:
			if _collided_with__25.is_in_group("player"):
				_collision_entered__25 = false
				return true
		_collision_entered__25 = false  # Didn't match filter
		return false
	).call()
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		var _msg_targets = get_tree().get_nodes_in_group("player")
		for _target in _msg_targets:
			if _target.has_method("_on_message_received"):
				_target._on_message_received("coin", "", self)
		get_tree().create_timer(0.10).timeout.connect(queue_free)
# === LOGIC BRICKS END ===
