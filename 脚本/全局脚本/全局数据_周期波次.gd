extends Node
#生命周期为波次，每波次开始时重置，主要是道具的动态变量

var 数据初始镜像 : Dictionary = {}

var 道具动态特殊变量字典 : Dictionary = {}

#var 当前波次已结束 : bool = false
var 记录升级次数 : int = 0
var 当前敌人生命值倍率 : float = 0.5
var 当前敌人伤害倍率 : float = 0.5
var 当前敌人掉落概率 : float = 0.5

#道具动态特殊变量

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	全局方法.记录数据初始镜像(self, 数据初始镜像)
