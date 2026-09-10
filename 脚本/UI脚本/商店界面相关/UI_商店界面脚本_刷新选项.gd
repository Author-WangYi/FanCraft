extends Node2D

var 总节点 : Node = null
var 放大节点_3倍 : Node2D = null
var 选中图片 : Sprite2D = null

var 数值 : RichTextLabel = null
var gui输入区域 : Control = null

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_商品显示渲染.connect(渲染更新)
	放大节点_3倍 = self.get_node("放大节点_3倍")
	选中图片 = 放大节点_3倍.get_node("选中图片")
	
	数值 = self.get_node("数值")
	gui输入区域 = 放大节点_3倍.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 渲染更新() -> void:
	数值.text = str(int(总节点.当前刷新价格))
	if 总节点.选择模式 == 3:
		选中图片.visible = true
	else:
		选中图片.visible = false

func 鼠标进入处理() -> void:
	总节点.切换查看刷新选项()

func gui输入处理(输入事件 : InputEvent) -> void:
	if not 输入事件.is_pressed():
		return
	if 输入事件 is InputEventMouseButton:
		if 输入事件.button_index == MOUSE_BUTTON_LEFT:
			总节点.确认查看刷新选项()
