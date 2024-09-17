@tool

extends Node2D

const RADIUS = 8


func _convert_coordinates_ci2b(ci_pos: Vector2) -> Vector2i:
	ci_pos -= Vector2(16, 16)
	var y:int = int(ci_pos.y / (2 * sin(deg_to_rad(60)) * RADIUS))
	var v = ci_pos.y - y * (2 * sin(deg_to_rad(60)) * RADIUS)
	if v > RADIUS:
		y += 1
	
	var x:int
	if y % 2 == 0:
		x = ((ci_pos.x + RADIUS) / (2 * RADIUS)) as int
	else:
		x = (ci_pos.x / (2 * RADIUS)) as int
	return Vector2i(x, y)

## 泡泡坐标转成画布项坐标
func _convert_coordinates_b2ci(bubble_pos: Vector2i) -> Vector2:
	var x:float
	var y:float = bubble_pos.y * 2 * sin(deg_to_rad(60)) * RADIUS
	if bubble_pos.y % 2 == 0:
		x = bubble_pos.x * 2 * RADIUS
	else:
		x = bubble_pos.x * 2 * RADIUS + RADIUS
	return Vector2(x, y) + Vector2(16, 16)


func _on_child_entered_tree(bubble: Bubble) -> void:
	bubble.position = _convert_coordinates_b2ci(_convert_coordinates_ci2b(bubble.position))
