class_name Arena extends Node2D

const BLACK = preload("res://resource/black.gdshader")
var shader_material: ShaderMaterial = ShaderMaterial.new()

@export var bubbles: Node2D
@export var is_level: bool = true

@onready var playfield: Playfield = $Playfield
@onready var launcher: Launcher = $Launcher

@onready var audio_ready: AudioStreamPlayer = $audio_ready
@onready var audio_go: AudioStreamPlayer = $audio_go
@onready var audio_defeat_1: AudioStreamPlayer = $audio_defeat_1
@onready var audio_defeat_2: AudioStreamPlayer = $audio_defeat_2
@onready var audio_victory: AudioStreamPlayer = $audio_victory
@onready var bgm: AudioStreamPlayer = $bgm


func _init() -> void:
	Global.level = self
	Global.game_state = Global.GameState.GAME_MENU
	
	shader_material.shader = BLACK

func _ready() -> void:
	playfield.victory.connect(_on_victory)
	playfield.defeat.connect(_on_defeat)
	
	audio_ready.play()
	await audio_ready.finished
	audio_go.play()
	await audio_go.finished 
	Global.game_state = Global.GameState.GAME_RUNNING


func build() -> void:
	for i in bubbles.get_children():
		playfield.add_bubble_by_ci_coordinates(i, false)


func _on_defeat() -> void:
	bgm.stop()
	Global.game_state = Global.GameState.GAME_LOSE
	print("lose")
	audio_defeat_1.play()
	launcher.defeat()
	var data = playfield.data
	# 将泡泡都变黑一些
	for row in range(data.size() - 1, -1, -1):
		for col in range(data[row].size() - 1, -1, -1):
			var bubble:Bubble = data[row][col]
			if bubble == null:
				continue
			
			bubble.animated_sprite_2d.material = shader_material
			await get_tree().create_timer(0.05).timeout
	
	audio_defeat_2.play()
	await get_tree().create_timer(2).timeout
	get_tree().reload_current_scene()


func _on_victory() -> void:
	bgm.stop()
	Global.game_state = Global.GameState.GAME_WIN
	audio_victory.play()
	await audio_victory.finished
	audio_go.play()
	await audio_go.finished
	print("win")
	if is_level:
		Global.next_level()
