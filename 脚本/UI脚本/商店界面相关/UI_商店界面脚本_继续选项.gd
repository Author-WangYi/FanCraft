extends Node2D

var 总节点 : Node = null
var 放大节点_3倍 : Node2D = null
var 选中图片 : Sprite2D = null
var 界面模式 : int = 1

var 选项文本 : RichTextLabel = null
var gui输入区域 : Control = null

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_商品显示渲染.connect(渲染更新)
	总节点.通知_确认生成商店界面.connect(初始化_商店界面)
	总节点.通知_确认生成奖励界面.connect(初始化_奖励界面)

func 渲染更新() -> void:
	match 界面模式:
		1:
			选项文本.text = 全局方法.解析自定义文本(全局数据库.通用文本数据库["继续下一波选项文本"])
		2:
			选项文本.text = "+" + str(int(总节点.当前奖励金钱数))
	if 总节点.选择模式 == 2:
		选中图片.visible = true
	else:
		选中图片.visible = false

func 初始化_商店界面() -> void:
	界面模式 = 1
	self.get_node("分类节点_奖励界面").queue_free()
	var 主节点 = self.get_node("分类节点_商店界面")
	主节点.visible = true
	放大节点_3倍 = 主节点.get_node("放大节点_3倍")
	选中图片 = 放大节点_3倍.get_node("选中图片")
	选项文本 = 主节点.get_node("选项文本")
	gui输入区域 = 放大节点_3倍.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 初始化_奖励界面() -> void:
	界面模式 = 2
	self.get_node("分类节点_商店界面").queue_free()
	var 主节点 = self.get_node("分类节点_奖励界面")
	主节点.visible = true
	放大节点_3倍 = 主节点.get_node("放大节点_3倍")
	选中图片 = 放大节点_3倍.get_node("选中图片")
	选项文本 = 主节点.get_node("选项文本")
	gui输入区域 = 放大节点_3倍.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 鼠标进入处理() -> void:
	总节点.切换查看继续选项()

func gui输入处理(输入事件 : InputEvent) -> void:
	if not 输入事件.is_pressed():
		return
	if 输入事件 is InputEventMouseButton:
		if 输入事件.button_index == MOUSE_BUTTON_LEFT:
			总节点.确认查看继续选项()
