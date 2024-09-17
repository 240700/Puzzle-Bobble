class_name Friend extends Sprite2D

const interval = 0.1

var velocity: Vector2 = Vector2.ZERO

const dict = {
	0: "friend_blue.png",
	1: "friend_red.png",
	2: "friend_purple.png",
	3: "friend_black.png",
	4: "friend_yellow.png",
	5: "friend_green.png",
	6: "friend_chocolate.png",
	7: "friend_silver.png"
}


func _process(delta: float) -> void:
	if not velocity.is_zero_approx():
		velocity += Global.gravity * delta
		position += velocity * delta
		rotate(2 * TAU * delta)


func freedom(bubble: Bubble):
	if dict.has(bubble.type):
		var filename = dict.get(bubble.type)
		texture = load("res://asset/friend/%s" % filename)
		position = bubble.position
		scale = Vector2.ZERO
		create_tween().tween_property(self, "scale", Vector2.ONE * 0.75, 0.3)
		velocity = Vector2.RIGHT.rotated(deg_to_rad(randf_range(-115, -65))) * 150
