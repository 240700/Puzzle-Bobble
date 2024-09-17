@tool

extends Node2D

const RADIUS = 8

## 12行
const ROW_COUNT = 12
## 8列
const COL_COUNT = 8

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	
	for row in ROW_COUNT - 2:
		for col in COL_COUNT:
			if row % 2 != 0 and col == 7:
				continue
			
			var pos = _convert_coordinates_b2ci(Vector2i(col, row))
			draw_circle(pos, RADIUS, Color.WHITE, false)


func _convert_coordinates_b2ci(bubble_pos: Vector2i) -> Vector2:
	var x:float
	var y:float = bubble_pos.y * 2 * sin(deg_to_rad(60)) * RADIUS
	if bubble_pos.y % 2 == 0:
		x = bubble_pos.x * 2 * RADIUS
	else:
		x = bubble_pos.x * 2 * RADIUS + RADIUS
	return Vector2(x, y) + Vector2(16, 16)
