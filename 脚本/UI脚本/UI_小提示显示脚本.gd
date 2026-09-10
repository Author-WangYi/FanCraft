extends Node2D

var 文本 : RichTextLabel = null
var 显示计时器 : Timer = null

@export var 格子序号 : int = 1

func _ready() -> void:
	文本 = self.get_node("文本")
	显示计时器 = self.get_node("显示计时器")
	显示计时器.timeout.connect(更换小提示文本)
	
	显示计时器.wait_time = 5
	显示计时器.start()
	
	更换小提示文本()

func 更换小提示文本() -> void:
	var 随机键 = 全局数据库.小提示文本数据库.keys().pick_random()
	文本.text = 全局数据库.小提示文本数据库[随机键]
