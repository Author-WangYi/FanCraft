extends Node2D

var 文本 : RichTextLabel = null

@export var 格子序号 : int = 1

func _ready() -> void:
	文本 = self.get_node("文本")
	if 全局数据_环境.Steam特供版 == false:
		文本.text = 全局数据库.版本更新内容数据库[全局数据_环境.游戏版本号]["版本号文本"]
	else:
		文本.text = 全局数据库.版本更新内容数据库[全局数据_环境.游戏版本号]["Steam版本号文本"]
