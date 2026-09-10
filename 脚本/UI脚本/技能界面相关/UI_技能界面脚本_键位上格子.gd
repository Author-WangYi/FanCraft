extends Node2D

var 总节点 : Node = null

var 等级展示框 : Sprite2D = null
var 技能图标 : Sprite2D = null
var 技能数量显示 : RichTextLabel = null
var 选中图片 : Sprite2D = null

var gui输入区域 : Control = null

@export var 格子序号 : int = 1

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_技能显示渲染.connect(渲染更新)
	
	等级展示框 = self.get_node("等级展示框")
	技能图标 = self.get_node("技能图标")
	技能数量显示 = self.get_node("技能数量显示")
	选中图片 = self.get_node("选中图片")
	
	gui输入区域 = self.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 渲染更新() -> void:
	var 技能编号 = 全局数据_周期对局.技能编号_键位[格子序号]
	if 技能编号 == 0:
		等级展示框.texture = null
		技能图标.texture = null
		技能数量显示.text = ""
	else:
		var 技能等级 = 总节点.当前角色技能数据库[技能编号]["技能等级"]
		var 拼接等级框键名 = "背包_展示框_等级%d" % 技能等级
		等级展示框.texture = 全局数据库.图片资源预加载数据库[拼接等级框键名]
		var 拼接图标键名 = 总节点.当前角色名称 + ("_技能图标%d" % 技能编号)
		技能图标.texture = 全局数据库.图片资源预加载数据库[拼接图标键名]
		var 技能数量 = 全局数据_周期对局.技能持有数据[技能编号]
		if 技能数量 == -999:
			技能数量显示.text = ""
		else:
			技能数量显示.text = str(技能数量)
	if 总节点.选择模式 == 1 and 全局数据_系统.当前查看技能键位组合 == 格子序号:
		选中图片.visible = true
	else:
		选中图片.visible = false

func 鼠标进入处理() -> void:
	全局数据_系统.当前查看技能键位组合 = 格子序号
	总节点.切换查看键位()

func gui输入处理(输入事件 : InputEvent) -> void:
	if not 输入事件.is_pressed():
		return
	if 输入事件 is InputEventMouseButton:
		if 输入事件.button_index == MOUSE_BUTTON_LEFT:
			总节点.确认查看键位()
