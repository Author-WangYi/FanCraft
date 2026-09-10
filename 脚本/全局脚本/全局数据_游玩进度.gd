extends Node
#生命周期为无限，玩家存档相关，绝对不能重置

var 游戏存档版本号 : int = 0

var 角色通过最大波次 : Dictionary = {}
var 道具解锁数据 : Dictionary = {}
var 首次进入游戏 : bool = true

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
