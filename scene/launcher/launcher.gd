class_name Launcher extends Node2D

const SPEED = 300
const MIN_DEGREE = -85
const MAX_DEGREE = 85

@export var playfield: Playfield

@onready var bubble_scene:PackedScene = preload("res://scene/bubble/bubble.tscn")

@onready var arrow: Sprite2D = $Arrow
@onready var 喷嘴: AnimatedSprite2D = $"喷嘴"
@onready var bub: AnimatedSprite2D = $Bub
@onready var bob: AnimatedSprite2D = $Bob

@onready var pad: AnimatedSprite2D = $Pad
@onready var wheel: AnimatedSprite2D = $Wheel

@onready var inside_point: Marker2D = $InsidePoint
@onready var launch_point: Marker2D = $LaunchPoint
@onready var carry_point: Marker2D = $CarryPoint
@onready var exit_point: Marker2D = $ExitPoint

@onready var current_bubble: Bubble = $CurrentBubble
@onready var next_bubble: Bubble = $NextBubble

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


var can_launch: bool = true

## 范围在[-85, 85]
var direction: float = 0:
	set = set_direction


func _ready() -> void:
	assert(playfield != null, "没有为 launcher 配置 playfield")
	
	current_bubble.queue_free()
	next_bubble.queue_free()
	
	current_bubble = spawn_bubble(exit_point)
	current_bubble.global_position = launch_point.global_position
	
	next_bubble = spawn_bubble(exit_point)
	next_bubble.global_position = exit_point.global_position


func launch():
	if not can_launch:
		return
	can_launch = false
	
	audio_stream_player.play()
	
	bub.play("blow")
	喷嘴.play("default")
	#await bub.animation_finished
	await get_tree().create_timer(0.1).timeout
	
	var arrow_direcion_degree = direction - 90
	current_bubble.read_to_launch()
	current_bubble.velocity = Vector2.from_angle(deg_to_rad(arrow_direcion_degree)) * SPEED
	
	await get_tree().create_timer(0.1).timeout
	if Global.game_state != Global.GameState.GAME_RUNNING:
		return
	reload()
	

## 生成新的泡泡
func next():
	var b = spawn_bubble(inside_point)
	b.global_position = inside_point.global_position
	b.scale = Vector2(0.3, 0.3)
	
	current_bubble = next_bubble
	next_bubble = b
	
	var tween = create_tween()
	tween.tween_property(next_bubble, "scale", Vector2.ONE, 0.2)
	tween.parallel().tween_property(next_bubble, "global_position", exit_point.global_position, 0.2)


func spawn_bubble(sibling_node: Node) -> Bubble:
	var type_arr = []
	for key in playfield.bubble_dictionary:
		if key < 0 or key >=8:
			continue
		
		if playfield.bubble_dictionary[key] != 0:
			type_arr.append(key)
	
	var bubble: Bubble = bubble_scene.instantiate()
	if type_arr.is_empty():
		bubble.type = randi_range(0, 7)
	else:
		bubble.type = type_arr.pick_random()
	
	sibling_node.add_sibling(bubble)
	bubble.collision_shape_2d.disabled = true
	return bubble


## 装填泡泡
func reload():
	next()
	bub.play("carry")
	var tween = create_tween()
	tween.tween_property(current_bubble, "global_position", carry_point.global_position, 0.1).set_delay(0.1)
	tween.tween_property(current_bubble, "global_position", launch_point.global_position, 0.1)
	tween.tween_callback(func():bub.play("default"))


## 属性direction 的setter
func set_direction(new_value):
	new_value = clampf(new_value, MIN_DEGREE, MAX_DEGREE)
	var frame_index = wheel.frame
	bob.frame = frame_index
	if new_value > direction:
		wheel.play("default")
		pad.play("default")
		bob.play("转轮")
	elif new_value < direction:
		wheel.play_backwards("default")
		pad.play_backwards("default")
		bob.play_backwards("转轮")
	else:
		wheel.pause()
		pad.pause()
		bob.pause()
	
	direction = new_value
	arrow.rotation_degrees = direction 


func _finit_rotate():
	wheel.pause()
	pad.pause()
	bob.play("default")


func defeat() -> void:
	bob.play("慌张")
	bub.play("翻滚")
	await bub.animation_finished
	bub.play("晕倒")
