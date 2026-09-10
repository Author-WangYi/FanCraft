extends Area2D

var 主节点 : Node = null
var 对象内容节点 : Node = null
var 状态机模块 : Node = null

func _ready() ->void:
	主节点 = self.owner
	对象内容节点 = 主节点.get_node("对象内容节点")
	状态机模块 = 主节点.get_node("状态机模块")
	self.area_entered.connect(状态机模块.仅检测型_检测到受伤区域进入)
