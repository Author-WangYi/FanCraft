extends Node2D

var 数值显示 : RichTextLabel

func _ready() -> void:
	数值显示 = self.get_node("数值显示")
