extends Node2D

var 记录经验值 : float = 0
var 记录经验值最大 : float = 0
var 放大节点_6倍  : Node2D = null
var 填充 : ColorRect = null
var 填充最大缩放x : float = 160

func _ready() -> void:
	放大节点_6倍 = self.get_node("放大节点_6倍")
	填充 = 放大节点_6倍.get_node("填充")

func _physics_process(_步进时间 : float) -> void:
	var 获取经验值 = 全局数据_周期对局.经验值
	var 获取经验值最大 = 全局数据_周期对局.经验值最大
	if 获取经验值 != 记录经验值 or 获取经验值最大 != 记录经验值最大:
		var 计算填充比例 = max(获取经验值 / 获取经验值最大, 0)
		填充.scale.x = 计算填充比例 * 填充最大缩放x
		记录经验值 = 获取经验值
		记录经验值最大 = 获取经验值最大
