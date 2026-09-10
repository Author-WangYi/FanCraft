extends Control

var 下一个场景名称 : String = ""
var 是否等待通知框 : bool = true
var 缓冲时间 : float = 0

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	全局数据_系统.是否禁用打开背包界面 = true
	全局数据_系统.是否禁用打开技能界面 = true
	全局数据_系统.是否禁用打开菜单界面 = true

func _physics_process(步进时间 : float) -> void:
	if 是否等待通知框 == true:
		if 全局数据_系统.存在通知未结束数量 == 0:
			缓冲时间 -= 步进时间
			if 缓冲时间 <= 0:
				过渡结束()
	else:
		缓冲时间 -= 步进时间
		if 缓冲时间 <= 0:
			过渡结束()

func 过渡结束() -> void:
	get_tree().paused = false
	全局方法.切换场景(下一个场景名称, false)
