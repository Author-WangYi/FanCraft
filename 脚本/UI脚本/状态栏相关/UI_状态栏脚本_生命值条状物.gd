extends Node2D

var 记录生命值 : float = 0
var 记录生命值最大 : float = 0
var 填充图片 : Node = null
var 填充最大缩放x : float
var 填充最大缩放y : float

func _ready() -> void:
	填充图片 = self.get_node("填充")
	填充最大缩放x = 填充图片.scale.x
	填充最大缩放y = 填充图片.scale.y

func _physics_process(_步进时间 : float) -> void:
	if is_instance_valid(全局数据_系统.当前游玩角色状态机模块实例):
		var 获取生命值 = 全局数据_系统.当前游玩角色状态机模块实例.生命值
		var 获取生命值最大 = 全局数据_系统.当前游玩角色状态机模块实例.生命值最大
		if 获取生命值 != 记录生命值 or 获取生命值最大 != 记录生命值最大:
			var 计算填充比例 = max(获取生命值 / 获取生命值最大, 0)
			填充图片.scale.x = 计算填充比例 * 填充最大缩放x
			记录生命值 = 获取生命值
			记录生命值最大 = 获取生命值最大
