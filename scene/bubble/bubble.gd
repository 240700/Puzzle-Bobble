@tool
class_name Bubble extends CharacterBody2D

## 泡泡类型
enum Type{
	NORMAL_BLUE,
	NORMAL_RED,
	NORMAL_PURPLE,
	NORMAL_BLACK,
	NORMAL_YELLOW,
	NORMAL_GREEN,
	NORMAL_CHOCOLATE,
	NORMAL_SILVER,
	RAINBOW,
	STAR,
	BOWLING_BALL,
	NOTHING = -1 # 给算法用
}

@export var type: Type = Type.NORMAL_BLUE:
	set = _set_type

## 泡泡坐标
var bubble_coordinates: Vector2i
@export var animated_sprite_2d: AnimatedSprite2D 
@export var collision_shape_2d: CollisionShape2D 

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

## 是否在下落
var falling: bool = false:
	set(value):
		falling = value
		if falling:
			collision_shape_2d.disabled = true


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if global_position.y > ProjectSettings.get_setting("display/window/size/viewport_height"):
		queue_free()
	
	if falling:
		velocity += Global.gravity * delta
		move_and_slide()
	elif not velocity.is_zero_approx():
		var collision = move_and_collide(velocity * delta)
		if collision:
			_collision(collision)


func _collision(collision: KinematicCollision2D):
	audio_stream_player.play()
	var launcher: Launcher = get_tree().get_first_node_in_group("Launcher")
	
	var collider = collision.get_collider()
	if collider is StaticBody2D: # 碰到墙
		velocity = velocity.bounce(collision.get_normal())
	else: # 碰到顶部或别的泡泡
		velocity = Vector2.ZERO
		var playfield: Playfield = get_tree().get_first_node_in_group("Playfield")
		playfield.add_bubble_by_ci_coordinates(self)
		launcher.can_launch = true
		


func read_to_launch():
	collision_shape_2d.disabled = false


func play_flash():
	animated_sprite_2d.play(BubbleAnimation.flash)
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play(BubbleAnimation.default)


func boom():
	animated_sprite_2d.play(BubbleAnimation.boom)
	await animated_sprite_2d.animation_finished
	queue_free()


func fall():
	falling = true
	

func is_normal_bubble() -> bool:
	if type >= 0 and type <= 7:
		return true
	
	return false


func _set_type(_type: Type):
	type = _type
	match type:
		Type.NORMAL_BLUE:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_blue.tres")
		Type.NORMAL_RED:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_red.tres")
		Type.NORMAL_PURPLE:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_purple.tres")
		Type.NORMAL_BLACK:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_black.tres")
		Type.NORMAL_YELLOW:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_yellow.tres")
		Type.NORMAL_GREEN:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_green.tres")
		Type.NORMAL_CHOCOLATE:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_chocolate.tres")
		Type.NORMAL_SILVER:
			animated_sprite_2d.sprite_frames = load("res://resource/normal_bubble/bubble_silver.tres")
	animated_sprite_2d.play(BubbleAnimation.default)
	

class BubbleAnimation:
	const default: StringName = &"default"
	const flash: StringName = &"flash"
	const boom: StringName = &"boom"
	
