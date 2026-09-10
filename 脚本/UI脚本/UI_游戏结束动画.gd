extends Control

var 等待时间 : float = 4

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func _physics_process(步进时间 : float) -> void:
	等待时间 -= 步进时间
	if 等待时间 <= 0:
		等待结束()

func 等待结束() -> void:
	get_tree().paused = false
	全局方法.切换场景("标题界面场景", false, false, 0, 0)
