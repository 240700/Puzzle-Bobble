class_name Playfield extends Node2D

const RADIUS:float = 8.0
## 12行
const ROW_COUNT = 12
## 8列
const COL_COUNT = 8

signal victory
signal defeat


var friend_scene: PackedScene = load("res://scene/friend/friend.tscn")

## 用于将算法坐标与显示的画面坐标相匹配。例如当顶部机关下降时，画面下降，算法的坐标原点也应该下降。
var v_offset = 16
var h_offset = 16

## 二维数组，存放泡泡对象，不包含发射台。
var data: Array = []

## 字典类型，key 为 泡泡类型， value 为此类型泡泡的数量
var bubble_dictionary = {}
## 场地中泡泡的总数，不包含发射台。
var bubble_count = 0 :
	set(value):
		bubble_count = value
		if bubble_count == 0:
			_victory() # NOTE 胜利条件
			pass

## 陷阱机关下降级别 
var trap_level: int = 0

## 场地中的泡泡都放在了这个节点中
@onready var bubbles: Node2D = $bubbles
## 小伙伴们都挂载在这个节点下
@onready var friends: Node2D = $friends

@onready var trap: CharacterBody2D = $Shade/Trap
## 将算法相关的一些代码放入了 helper 中
@onready var helper: Helper = $Helper
## 定时启动陷阱机关
@onready var timer: Timer = $Timer


## 天花板的纹理
@export var ceilling_texture: Texture
## 墙的纹理
@export var wall_texture: Texture
## 机关的纹理
@export var trap_texture: Texture

## 关卡设计的泡泡
@export var level_bubbles_node2d: Node2D

@export var descend_interval: Array[float]

@onready var audio_clear: AudioStreamPlayer = $audio_clear
@onready var audio_fall_clear: AudioStreamPlayer = $audio_fall_clear

func _init():
	for i in ROW_COUNT:
		var row = []
		data.append(row)
		for j in COL_COUNT:
			row.append(null)
			


func _ready() -> void:
	if trap_texture != null:
		var trap_sprite: Sprite2D = $Shade/Trap/TrapSprite
		trap_sprite.texture = trap_texture
	if wall_texture != null:
		var wall_sprite: Sprite2D = $Wall/WallSprite
		wall_sprite.texture = wall_texture
	if ceilling_texture != null:
		var ceilling_sprite: Sprite2D = $CeillingSprite
		ceilling_sprite.texture = ceilling_texture
	
	if level_bubbles_node2d != null:
		for i: Bubble in level_bubbles_node2d.get_children():
			add_bubble_by_ci_coordinates(i, false)
	
	timer.start(descend_interval.pop_front())


## 根据泡泡坐标系坐标 添加泡泡。做测试用的。
## @deprecated  已废弃，无法正常使用
func add_bubble_by_bubble_coordinates(bubble: Bubble, bubble_pos: Vector2i = Vector2(-1, -1)):
	if bubble_pos == Vector2i(-1, -1):
		bubble_pos = bubble.bubble_coordinates
		
	data[bubble_pos.y][bubble_pos.x] = bubble
	bubble.bubble_coordinates = bubble_pos
	bubble.global_position = to_global(_convert_coordinates_b2ci(bubble_pos))
	bubble.reparent(bubbles)


## 根据画布项标系坐标 添加泡泡
## bubble: 要添加的泡泡
## react: 是否要与场地中已有的泡泡发生反应（三个相同就消掉）。在构建关卡时通常设置为false
func add_bubble_by_ci_coordinates(bubble: Bubble, react: bool = true):
	var bubble_pos = _convert_coordinates_ci2b(to_local(bubble.global_position))
	data[bubble_pos.y][bubble_pos.x] = bubble
	bubble.bubble_coordinates = bubble_pos
	bubble.global_position = to_global(_convert_coordinates_b2ci(bubble_pos))
	bubble.reparent(bubbles)
	
	bubble_count += 1
	if bubble_dictionary.has(bubble.type):
		bubble_dictionary[bubble.type] += 1
	else:
		bubble_dictionary[bubble.type] = 1
	
	if bubble_pos.y >= 11 - trap_level:
		_defeat() # NOTE 失败
		return 
	
	if react:
		_add_post_process(bubble_pos)


## 泡泡坐标转成画布项坐标
func _convert_coordinates_b2ci(bubble_pos: Vector2i) -> Vector2:
	var x:float
	var y:float = bubble_pos.y * 2 * sin(deg_to_rad(60)) * RADIUS
	if bubble_pos.y % 2 == 0:
		x = bubble_pos.x * 2 * RADIUS
	else:
		x = bubble_pos.x * 2 * RADIUS + RADIUS
	return Vector2(x, y) + Vector2(h_offset, v_offset)


## 将圆心的画布项坐标转成泡泡坐标
func _convert_coordinates_ci2b(ci_pos: Vector2) -> Vector2i:
	ci_pos -= Vector2(h_offset, v_offset)
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


## 添加泡泡后需要做的处理
func _add_post_process(bubble_pos: Vector2i):
	var a = helper.floodfill(bubble_pos)
	if a.size() >= 3: # 3个以上就消掉
		audio_clear.play()
		var a_bubbles = helper.erase_by_arr(a)
		for i in a_bubbles:
			i.boom()
			var friend: Friend = friend_scene.instantiate()
			friend.freedom(i) 
			friends.add_child(friend)
			
			bubble_dictionary[i.type] -= 1
		
		await get_tree().create_timer(0.1).timeout
		bubble_falling()
		bubble_count -= a.size()
		
	else: # 小于3个就闪一下
		var bubble: Bubble = data[bubble_pos.y][bubble_pos.x]
		bubble.play_flash()
	
	


## 处理没有与顶部直接或间接相连的泡泡，让它们掉下来
func bubble_falling() -> void:
	var b = helper.get_isolate()
	if not b.is_empty():
		audio_fall_clear.play()
		bubble_count -= b.size()
		var b_bubbles = helper.erase_by_arr(b)
		for i in b_bubbles:
			i.fall()
			bubble_dictionary[i.type] -= 1


## 机关陷阱下落
func trap_descend():
	trap_level += 1
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "v_offset", v_offset + 16, 0.3)
	tween.parallel().tween_property(trap, "position:y", trap.position.y + 16, 0.3)
	tween.parallel().tween_property(bubbles, "position:y", bubbles.position.y + 16, 0.3)
	tween.tween_callback(func(): check_death_area())
	
	if not descend_interval.is_empty():
		timer.start(descend_interval.pop_front())


## 检查死区是否有场地的泡泡
func check_death_area():
	var row:Array = data[10 - trap_level]
	var has_bubble = row.any(func(i:Bubble): return i != null)
	if has_bubble:
		_defeat()  # 失败
	


func _defeat() -> void:
	defeat.emit()
	timer.stop()
	pass


func _victory() -> void:
	victory.emit()
	timer.stop()
	pass
