class_name Helper extends Node

@onready var playfield: Playfield = $".."


## 获取直接相连的泡泡的坐标
func _get_neighbors_pos(bubble_pos: Vector2i, type: Bubble.Type = Bubble.Type.NOTHING) -> Array[Vector2i]:
	var x = bubble_pos.x
	var y = bubble_pos.y
	
	var pos_array: Array[Vector2i] = []
	var l = Vector2i(x - 1, y)
	var r = Vector2i(x + 1, y)
	pos_array.append(l)	
	pos_array.append(r)
	
	if y % 2 == 0:
		var t_l = Vector2i(x - 1, y - 1)
		var t_r = Vector2i(x, y - 1)
		var b_l = Vector2i(x - 1, y + 1)
		var b_r = Vector2i(x, y + 1)
		pos_array.append(t_l)
		pos_array.append(t_r)
		pos_array.append(b_l)
		pos_array.append(b_r)
	else:
		var t_l = Vector2i(x, y - 1)
		var t_r = Vector2i(x + 1, y - 1)
		var b_l = Vector2i(x, y + 1)
		var b_r = Vector2i(x + 1, y + 1)
		pos_array.append(t_l)
		pos_array.append(t_r)
		pos_array.append(b_l)
		pos_array.append(b_r)
	
	var result_pos_arr: Array[Vector2i] = []
	for i in pos_array:
		if type != Bubble.Type.NOTHING: # 指定了泡泡类型
			if _pick(i, type):
				result_pos_arr.append(i)
		else: # 没有指定泡泡类型
			if _pick(i):
				result_pos_arr.append(i)
	
	return result_pos_arr


## 对给定坐标进行挑拣。判断其是否是具有价值
func _pick(bubble_pos: Vector2i, type: Bubble.Type = Bubble.Type.NOTHING) -> bool:
	## 不再棋盘内
	if not _is_within_bounds(bubble_pos):
		return false
	
	## 指定坐标没有泡泡
	var bubble: Bubble = playfield.data[bubble_pos.y][bubble_pos.x]
	if bubble == null:
		return false
	
	## 如果指定了要匹配的泡泡类型
	if type != Bubble.Type.NOTHING:
		if bubble.type != type:
			return false
	
	return true


## 判断是否在泡泡棋盘界限内
func _is_within_bounds(bubble_pos: Vector2i) -> bool:
	var x = bubble_pos.x
	var y = bubble_pos.y
	
	if x < 0 || y < 0 || x >= playfield.COL_COUNT || y >= playfield.ROW_COUNT:
		return false
	
	return true


## 洪水填充算法，找出相连的泡泡。
## 基于栈的深度优先遍历
func floodfill(bubble_pos: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var type = playfield.data[bubble_pos.y][bubble_pos.x].type
	
	var data_dumplicate = playfield.data.duplicate(true)
	
	result.append(bubble_pos)
	#将获取到的节点擦除，避免重复访问
	playfield.data[bubble_pos.y][bubble_pos.x] = null
	
	var neighbors = _get_neighbors_pos(bubble_pos, type)
	
	result.append_array(neighbors)
	#将获取到的节点擦除，避免重复访问
	erase_by_arr(neighbors)
	
	while neighbors.size():
		var n = neighbors.pop_back()
		var arr = _get_neighbors_pos(n, type)
		neighbors.append_array(arr)
		
		result.append_array(arr)
		#将获取到的节点擦除，避免重复访问
		erase_by_arr(arr)
	
	#将数据还原
	playfield.data = data_dumplicate
	return result


## 返回不与顶部相连（直接或间接）的 泡泡的坐标
func get_isolate() -> Array[Vector2i]:
	var neighbors: Array[Vector2i] = []
	for i in playfield.COL_COUNT:
		if playfield.data[0][i] != null:
			neighbors.append(Vector2i(i, 0))
	
	var data_dumplicate = playfield.data.duplicate(true)
	
	while neighbors.size():
		var n = neighbors.pop_back()
		erase_by_arr([n])
		var arr = _get_neighbors_pos(n)
		neighbors.append_array(arr)
		
		#将获取到的节点擦除，避免重复访问
		erase_by_arr(arr)
	
	#清除掉与顶部相连的泡泡之后，剩下的就是我们想要的数据。
	var result: Array[Vector2i] = []
	for i in playfield.data.size():
		for j in playfield.data[i].size():
			if playfield.data[i][j] != null:
				result.append(Vector2i(j, i))
	
	#将数据还原
	playfield.data = data_dumplicate
	return result


## 根据给定的坐标，将场地中的数据信息设置为null
func erase_by_arr(bubble_pos_arr: Array[Vector2i]) -> Array[Bubble]:
	var result: Array[Bubble] = []
	for i in bubble_pos_arr:
		result.append(playfield.data[i.y][i.x])
		playfield.data[i.y][i.x] = null
		
	return result 
