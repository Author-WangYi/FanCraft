extends Node2D

var 总节点 : Node = null

var 白条 : ColorRect = null

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_技能显示渲染.connect(渲染更新)
	白条 = self.get_node("白条")

func 渲染更新() -> void:
	var 计算键位背包总页数 = ceil(float(总节点.当前键位背包技能数量) / 总节点.键位背包栏位页数最大)
	if 计算键位背包总页数 > 1:
		var 计算键位背包当前页数 = ceil(float(全局数据_系统.当前查看技能栏位数) / 总节点.键位背包栏位页数最大)
		var 翻页比例 = (计算键位背包当前页数 - 1) / (计算键位背包总页数 - 1)
		var 滑动条像素长度x = max(总节点.滑动条最大移动距离 / 计算键位背包总页数, 总节点.滑动条最小长度)
		var 滑动条实际移动距离x = 总节点.滑动条最大移动距离 - 滑动条像素长度x
		var 滑动条位置x = 滑动条实际移动距离x * 翻页比例
		var 滑动条位置y = 0
		白条.visible = true
		白条.size.x = 滑动条像素长度x
		白条.position.x = 滑动条位置x
		白条.position.y = 滑动条位置y
	else:
		白条.visible = false
