extends CanvasLayer

@export var 是否禁用打开背包界面 : bool = false
@export var 是否禁用打开技能界面 : bool = false
@export var 是否禁用打开菜单界面 : bool = false

func _ready() -> void:
	全局数据_系统.当前场景UI层实例 = self
	全局数据_系统.是否禁用打开背包界面 = 是否禁用打开背包界面
	全局数据_系统.是否禁用打开技能界面 = 是否禁用打开技能界面
	全局数据_系统.是否禁用打开菜单界面 = 是否禁用打开菜单界面
