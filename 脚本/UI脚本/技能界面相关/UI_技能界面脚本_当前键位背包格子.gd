extends Node2D

var 总节点 : Node = null

var 等级展示框 : Sprite2D = null
var 技能图标 : Sprite2D = null
var 展示框黑幕 : Sprite2D = null
var 技能数量显示 : RichTextLabel = null
var 选中图片 : Sprite2D = null

var gui输入区域 : Control = null

@export var 格子序号 : int = 1

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_技能显示渲染.connect(渲染更新)
	等级展示框 = self.get_node("等级展示框")
	技能图标 = self.get_node("技能图标")
	展示框黑幕 = self.get_node("展示框黑幕")
	技能数量显示 = self.get_node("技能数量显示")
	选中图片 = self.get_node("选中图片")
	
	gui输入区域 = self.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 渲染更新() -> void:
	var 计算键位背包当前页数 = ceil(float(全局数据_系统.当前查看技能栏位数) / 总节点.键位背包栏位页数最大)
	var 计算当前栏位数 : int = 格子序号 + (计算键位背包当前页数 - 1) * 总节点.键位背包栏位页数最大
	if 计算当前栏位数 > 总节点.当前键位背包技能数量:
		等级展示框.texture = null
		技能图标.texture = null
		展示框黑幕.visible = false
		技能数量显示.text = ""
	else:
		var 技能编号 = 总节点.当前键位背包技能编号列表[计算当前栏位数]
		var 技能等级 = 总节点.当前角色技能数据库[技能编号]["技能等级"]
		var 拼接等级框键名 = "背包_展示框_等级%d" % 技能等级
		等级展示框.texture = 全局数据库.图片资源预加载数据库[拼接等级框键名]
		var 拼接图标键名 = 总节点.当前角色名称 + ("_技能图标%d" % 技能编号)
		技能图标.texture = 全局数据库.图片资源预加载数据库[拼接图标键名]
		var 技能数量 = 全局数据_周期对局.技能持有数据[技能编号]
		if 技能编号 == 全局数据_周期对局.技能编号_键位[全局数据_系统.当前查看技能键位组合]:
			展示框黑幕.visible = true
		else:
			展示框黑幕.visible = false
		if 技能数量 == -999:
			技能数量显示.text = ""
		else:
			技能数量显示.text = str(技能数量)
			if 技能数量 == 0:
				展示框黑幕.visible = true
	if 总节点.选择模式 == 2 and 全局数据_系统.当前查看技能栏位数 == 计算当前栏位数:
		选中图片.visible = true
	else:
		选中图片.visible = false

func 鼠标进入处理() -> void:
	var 计算键位背包当前页数 = ceil(float(全局数据_系统.当前查看技能栏位数) / 总节点.键位背包栏位页数最大)
	var 尝试计算当前栏位数 : int = 格子序号 + (计算键位背包当前页数 - 1) * 总节点.键位背包栏位页数最大
	if 尝试计算当前栏位数 <= 总节点.当前键位背包技能数量:
		全局数据_系统.当前查看技能栏位数 = 尝试计算当前栏位数
		总节点.切换查看当前键位背包()

func gui输入处理(输入事件 : InputEvent) -> void:
	if not 输入事件.is_pressed():
		return
	if 输入事件 is InputEventMouseButton:
		if 输入事件.button_index == MOUSE_BUTTON_LEFT:
			var 计算键位背包当前页数 = ceil(float(全局数据_系统.当前查看技能栏位数) / 总节点.键位背包栏位页数最大)
			var 尝试计算当前栏位数 : int = 格子序号 + (计算键位背包当前页数 - 1) * 总节点.键位背包栏位页数最大
			if 尝试计算当前栏位数 <= 总节点.当前键位背包技能数量:
				全局数据_系统.当前查看技能栏位数 = 尝试计算当前栏位数
				总节点.确认查看当前键位背包()
