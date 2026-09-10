extends Control

signal 通知_选项文本显示渲染
signal 通知_选中图片渲染

var 选择模式 : int = 1  #1-选择标题文本中，2-查看操作说明中，3-继续游戏选项通知框
var 选择栏位数 : int = 1
var 栏位数最大 : int = 3

@export var 界面模式扩展 : int = 1  #生成时被指定：1-标题界面，2-菜单界面

var 黑幕图片 : ColorRect = null

var 选项文本字典 : Dictionary

func _ready() -> void:
	print("【程序运行测试】生成标题界面，_ready()开始运行，运行时间为：", Time.get_ticks_msec())
	
	黑幕图片 = self.get_node("黑幕图片")
	
	match 界面模式扩展:
		1:
			选项文本字典 = {1 : "开始游戏", 2 : "操作说明", 3 : "结束游戏"}
			黑幕图片.visible = false
			全局方法.读取存档()
			全局方法.重置全局数据_系统()
		2:
			选项文本字典 = {1 : "继续游戏", 2 : "操作说明", 3 : "退出游戏"}
			self.process_mode = Node.PROCESS_MODE_ALWAYS
			get_tree().paused = true
			全局数据_系统.角色输入许可 = false
			全局数据_系统.菜单界面已打开 = true
			self.z_index = 4
			黑幕图片.visible = true
	
	通知_选项文本显示渲染.emit()
	通知_选中图片渲染.emit()
	
	if 界面模式扩展 == 1 and 全局数据_游玩进度.首次进入游戏 == true:
		await get_parent().ready
		生成操作说明提示框()
		全局数据_游玩进度.首次进入游戏 = false

func _input(输入事件: InputEvent) -> void:
	if 全局数据_系统.UI输入许可:
		if 选择模式 == 1:
			if Input.is_action_just_pressed("操作→"):
				if 选择栏位数 < 栏位数最大:
					选择栏位数 += 1
					切换查看选项()
					全局方法.UI输入倒计时启动()
			elif Input.is_action_just_pressed("操作←"):
				if 选择栏位数 > 1:
					选择栏位数 -= 1
					切换查看选项()
					全局方法.UI输入倒计时启动()
			elif 输入事件.is_action_pressed("操作确认"):
				确认查看选项()
				全局方法.UI输入倒计时启动()
			elif 输入事件.is_action_pressed("菜单1") and 界面模式扩展 == 2:
				关闭菜单界面()
				全局方法.UI输入倒计时启动()

func 切换查看选项() -> void:
	选择模式 = 1
	通知_选中图片渲染.emit()

func 确认查看选项() -> void:
	match 界面模式扩展:
		1:
			match 选择栏位数:
				1:
					全局方法.播放音频("基础音效_按键声2")
					if 全局数据_周期对局.当前对局进行中 == 0:
						全局方法.切换场景("角色选择界面场景")
					else:
						生成继续游戏选项通知框()
				2:
					全局方法.播放音频("基础音效_按键声2")
					生成操作说明提示框()
				3:
					get_tree().quit()
		2:
			match 选择栏位数:
				1:
					全局方法.播放音频("基础音效_按键声2")
					关闭菜单界面()
				2:
					全局方法.播放音频("基础音效_按键声2")
					生成操作说明提示框()
				3:
					菜单界面退出游戏()

func 关闭菜单界面() -> void:
	全局数据_系统.菜单界面已打开 = false
	get_tree().paused = false
	全局方法.UI输入倒计时启动()
	self.queue_free()

func 菜单界面退出游戏() -> void:
	全局数据_系统.菜单界面已打开 = false
	get_tree().paused = false
	全局方法.切换场景("标题界面场景")

func 生成继续游戏选项通知框() -> void:
	选择模式 = 3
	var 生成通知框 = 全局数据库.UI资源预加载数据库["UI_继续游戏选项通知框"].instantiate()
	生成通知框.上层实例 = self
	全局数据_系统.当前场景UI层实例.add_child(生成通知框)

func 生成操作说明提示框() -> void:
	选择模式 = 2
	var 生成通知框 = 全局数据库.UI资源预加载数据库["UI_通知框2"].instantiate()
	生成通知框.上层实例 = self
	生成通知框.显示文本 = 全局数据库.通用文本数据库["操作说明"]
	生成通知框.水平对齐 = 0
	生成通知框.垂直对齐 = 0
	生成通知框.显示行间距 = 24
	生成通知框.显示时间 = -1
	生成通知框.是否启用按键关闭 = true
	全局数据_系统.当前场景UI层实例.add_child(生成通知框)

func 通知框已关闭() -> void:
	选择模式 = 1
	通知_选中图片渲染.emit()

func 继续游戏选项通知框已关闭(返回序号 : int) -> void:
	选择模式 = 1
	match 返回序号:
		0:
			通知_选中图片渲染.emit()
		1:
			全局方法.开始下一波次(true)
		2:
			全局方法.切换场景("角色选择界面场景")
