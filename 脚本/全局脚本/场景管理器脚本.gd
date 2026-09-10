extends Node2D

var 初始场景名称 : String = "标题界面场景"

var 当前场景 = null

func _ready():
	全局方法.场景管理器实例 = self
	if get_child_count() > 0:
		当前场景 = get_child(0)
	全局方法.切换场景(初始场景名称)
