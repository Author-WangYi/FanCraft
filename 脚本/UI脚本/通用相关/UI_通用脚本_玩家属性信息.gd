extends Node2D

var 总节点 : Node = null

var 玩家属性名称显示 : RichTextLabel = null
var 玩家属性数值显示 : RichTextLabel = null

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_玩家属性渲染.connect(渲染更新)
	
	玩家属性名称显示 = self.get_node("玩家属性名称显示")
	玩家属性数值显示 = self.get_node("玩家属性数值显示")

func 渲染更新() -> void:
	玩家属性名称显示.text = 全局方法.输出玩家属性名称字符串()
	玩家属性数值显示.text = 全局方法.输出玩家属性数值字符串()
