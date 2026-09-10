extends Node2D

var 总节点 : Node = null

var 数值 : RichTextLabel = null

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_商品显示渲染.connect(渲染更新)
	
	数值 = self.get_node("数值")

func 渲染更新() -> void:
	数值.text = str(int(全局数据_周期对局.金钱数))
