extends Area2D

var 主节点 : Node = null
var 对象内容节点 : Node = null
var 状态机模块 : Node = null

func _ready() ->void:
	主节点 = self.owner
	对象内容节点 = 主节点.get_node("对象内容节点")
	状态机模块 = 主节点.get_node("状态机模块")
	self.area_entered.connect(状态机模块.检测到受伤区域进入)
	状态机模块.重置攻击区域检测.connect(重置攻击区域检测)

func 重置攻击区域检测() ->void:
	状态机模块.清空已记录攻击对象列表()
	self.monitoring = false
	self.monitoring = true
