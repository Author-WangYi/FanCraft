extends Node2D

var 总节点 : Node = null

var 选中图片 : Sprite2D = null
var 文本显示 : RichTextLabel = null

var gui输入区域 : Control = null

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_技能显示渲染.connect(渲染更新)
	总节点.通知_继续下一波选项删除.connect(删除自身)
	
	选中图片 = self.get_node("选中图片")
	文本显示 = self.get_node("文本显示")
	
	gui输入区域 = self.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 渲染更新() -> void:
	文本显示.text = 全局方法.解析自定义文本(全局数据库.通用文本数据库["继续下一波选项文本"])
	if 总节点.选择模式 == 3:
		选中图片.visible = true
	else:
		选中图片.visible = false

func 删除自身() -> void:
	self.queue_free()

func 鼠标进入处理() -> void:
	总节点.切换查看继续下一波按钮()

func gui输入处理(输入事件 : InputEvent) -> void:
	if not 输入事件.is_pressed():
		return
	if 输入事件 is InputEventMouseButton:
		if 输入事件.button_index == MOUSE_BUTTON_LEFT:
			总节点.确认查看继续下一波按钮()
