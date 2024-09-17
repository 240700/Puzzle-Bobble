extends Node

const ROTATE_WEIGHT = 100

@onready var launcher: Launcher = $".."

func _process(delta: float) -> void:
	if Global.game_state != Global.GameState.GAME_RUNNING:
		return
	
	var axis = Input.get_axis("left", "right")
	if axis:
		launcher.direction += axis * ROTATE_WEIGHT * delta


func _unhandled_input(event: InputEvent) -> void:
	
	if Global.game_state != Global.GameState.GAME_RUNNING:
		return
	
	if event.is_action_pressed("launch"):
		launcher.launch()
	
	if event.is_action_released("left") or event.is_action_released("right"):
		launcher._finit_rotate()
