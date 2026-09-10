extends Node2D

var 总节点 : Node = null

var 放大节点_12倍 : Node = null
var 选中图片 : Sprite2D = null

var 选项文本 : RichTextLabel = null
var gui输入区域 : Control = null

@export var 格子序号 : int = 1

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_选项文本显示渲染.connect(文本显示渲染更新)
	总节点.通知_选中图片渲染.connect(选中图片渲染更新)
	
	放大节点_12倍 = self.get_node("放大节点_12倍")
	选中图片 = 放大节点_12倍.get_node("选中图片")
	
	选项文本 = self.get_node("选项文本")

	gui输入区域 = 放大节点_12倍.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 文本显示渲染更新() -> void:
	选项文本.text = 总节点.选项文本字典[格子序号]

func 选中图片渲染更新() -> void:
	if 总节点.选择模式 == 1 and 总节点.选择栏位数 == 格子序号:
		选中图片.visible = true
	else:
		选中图片.visible = false

func 鼠标进入处理() -> void:
	if 总节点.选择模式 == 1:
		总节点.选择栏位数 = 格子序号
		总节点.切换查看选项()

func gui输入处理(输入事件 : InputEvent) -> void:
	if 总节点.选择模式 == 1:
		if not 输入事件.is_pressed():
			return
		if 输入事件 is InputEventMouseButton:
			if 输入事件.button_index == MOUSE_BUTTON_LEFT:
				总节点.选择栏位数 = 格子序号
				总节点.确认查看选项()
