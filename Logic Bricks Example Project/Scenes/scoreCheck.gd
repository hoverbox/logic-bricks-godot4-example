extends Node3D

# === LOGIC BRICKS START ===
# Variables
var coin: int:
	get: return GlobalVars.coin
	set(val): GlobalVars.coin = val

# Logic brick state (1-30)
var _logic_brick_state: int = 1

func _process(delta: float) -> void:
	match _logic_brick_state:
		1:
			_logic_brick__5(delta)

func _logic_brick__5(_delta: float) -> void:
	# Sensor evaluation
	var sensor_0_active = (coin == 5)
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Change to specified scene
		get_tree().change_scene_to_file("res://Scenes/win screen.tscn")
# === LOGIC BRICKS END ===
