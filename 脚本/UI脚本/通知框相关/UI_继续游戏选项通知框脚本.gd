extends Control

signal 通知_选项文本显示渲染
signal 通知_选中图片渲染

var 上层实例 : Node = null
var 选择栏位数 : int = 1
var 栏位数最大 : int = 2

var 选项文本字典 : Dictionary

func _ready() -> void:
	全局数据_系统.存在通知未结束数量 += 1
	选项文本字典 = {1 : "继续游玩", 2 : "重新开始"}
	
	通知_选项文本显示渲染.emit()
	通知_选中图片渲染.emit()

func _input(输入事件: InputEvent) -> void:
	if 全局数据_系统.UI输入许可:
		if 输入事件.is_action_pressed("操作→"):
			if 选择栏位数 < 栏位数最大:
				选择栏位数 += 1
				切换查看选项()
				全局方法.UI输入倒计时启动()
		elif 输入事件.is_action_pressed("操作←"):
			if 选择栏位数 > 1:
				选择栏位数 -= 1
				切换查看选项()
				全局方法.UI输入倒计时启动()
		elif 输入事件.is_action_pressed("操作确认"):
			确认查看选项()
			全局方法.UI输入倒计时启动()
		elif 输入事件.is_action_pressed("菜单1") or 输入事件.is_action_pressed("操作取消"):
			取消查看选项()
			全局方法.UI输入倒计时启动()

func 切换查看选项() -> void:
	通知_选中图片渲染.emit()

func 确认查看选项() -> void:
	全局方法.播放音频("基础音效_按键声2")
	关闭通知框(选择栏位数)

func 取消查看选项() -> void:
	关闭通知框(0)

func 关闭通知框(序号 : int = 0) -> void:
	if is_instance_valid(上层实例):
		上层实例.继续游戏选项通知框已关闭(序号)
	全局数据_系统.存在通知未结束数量 -= 1
	self.queue_free()
