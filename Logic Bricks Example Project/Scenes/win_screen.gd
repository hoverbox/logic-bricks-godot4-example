extends Node3D

# === LOGIC BRICKS START ===
var _delay__8_elapsed: float = 0.0
@export var _text_node__8: Node

# Logic brick state (1-30)
var _logic_brick_state: int = 1

func _process(delta: float) -> void:
	match _logic_brick_state:
		1:
			_logic_brick__8(delta)

func _logic_brick__8(_delta: float) -> void:
	# Sensor evaluation
	# Delay sensor
	_delay__8_elapsed += _delta
	var sensor_0_active = false
	if _delay__8_elapsed >= 0.00:
		sensor_0_active = true
		_delay__8_elapsed = 0.0  # Reset timer
	
	# Controller logic
	var controller_active = sensor_0_active
	
	# Actuator execution
	if controller_active:
		# Update text display
		if not _text_node__8:
			push_warning("Text Actuator: No text node assigned to '_text_node__8' — drag a Label, Label3D, or RichTextLabel into the inspector")
		else:
			# Get variable (local or global)
			var _value
			if "coin" in self:
				_value = str(self.get("coin"))
			else:
				var _gv = get_node_or_null("/root/GlobalVars")
				if _gv and "coin" in _gv:
					_value = str(_gv.get("coin"))
				else:
					_value = "???"
			var _display_text = "You Got " + _value + " Coins"
			if _text_node__8 is Label or _text_node__8 is Label3D:
				_text_node__8.text = _display_text
			elif _text_node__8 is RichTextLabel:
				_text_node__8.text = _display_text
# === LOGIC BRICKS END ===
