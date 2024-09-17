extends Node

enum GameState {
	GAME_MENU,
	GAME_RUNNING,   # 游戏进行中
	GAME_WIN,       # 游戏胜利
	GAME_LOSE       # 游戏失败
}

var game_state: GameState = GameState.GAME_MENU

## 从项目配置中读取值
var gravity 

var level: Arena
var level_number: int = 0

##关卡文件所在目录
const dir_path = "res://level/"
##所有关卡文件路径
static var levels_path: Array[String] = []


static func _static_init() -> void:
	_init_levels()


func _init() -> void:
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity_vector") * \
		ProjectSettings.get_setting("physics/2d/default_gravity")


static func _init_levels() -> void:
	var dir:DirAccess = DirAccess.open(dir_path)
	var files_string = dir.get_files()
	for f in files_string :
		levels_path.append(dir_path + f)


func first_level() -> void:
	level_number = 0
	get_tree().change_scene_to_file(levels_path[0])


func next_level() -> void:
	level_number += 1
	if level_number < levels_path.size():
		#get_tree().change_scene_to_file(levels_path[level_number])
		var scene = load(levels_path[level_number])
		get_tree().change_scene_to_packed(scene)
	
