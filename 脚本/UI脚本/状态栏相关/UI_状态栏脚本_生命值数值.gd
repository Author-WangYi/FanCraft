extends Node2D

func _ready() -> void:
	if 全局数据_周期对局.道具持有数据.has(65):
		self.queue_free()
