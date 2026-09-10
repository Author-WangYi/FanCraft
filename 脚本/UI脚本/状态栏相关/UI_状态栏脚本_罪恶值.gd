extends Node2D

var 记录罪恶值 : float = 0
var 记录罪恶值最大 : float = 0

var 初始记录区间完成 : bool = false
var 记录左区间1 : float = 0
var 记录左区间2 : float = 0
var 记录右区间2 : float = 0
var 记录右区间1 : float = 0

var 左区间1图片 : ColorRect = null
var 左区间2图片 : ColorRect = null
var 右区间2图片 : ColorRect = null
var 右区间1图片 : ColorRect = null
var 区间图片最小x : float
var 区间图片最大x : float
var 区间图片最大移动x : float

var 条状物图片 : Sprite2D = null
var 条状物最大缩放x : float

func _ready() -> void:
	条状物图片 = self.get_node("条状物")
	条状物图片.visible = true
	条状物最大缩放x = 条状物图片.scale.x
	左区间1图片 = self.get_node("左区间1")
	左区间2图片 = self.get_node("左区间2")
	右区间2图片 = self.get_node("右区间2")
	右区间1图片 = self.get_node("右区间1")
	区间图片最小x = 左区间1图片.position.x
	区间图片最大x = 右区间1图片.position.x
	区间图片最大移动x = 区间图片最大x - 区间图片最小x

func _physics_process(_步进时间 : float) -> void:
	if is_instance_valid(全局数据_系统.当前游玩角色状态机模块实例):
		if 初始记录区间完成 == false:
			获取罪恶值区间值()
			初始记录区间完成 = true
		else:
			更新条状物()

func 更新条状物(强制更新 : bool = false) -> void:
	var 获取罪恶值 = 全局数据_系统.当前游玩角色状态机模块实例.罪恶值
	var 获取罪恶值最大 = 全局数据_系统.当前游玩角色状态机模块实例.罪恶值最大
	if 强制更新 == true or 获取罪恶值 != 记录罪恶值 or 获取罪恶值最大 != 记录罪恶值最大:
		var 计算填充比例 = max(获取罪恶值 / 获取罪恶值最大, 0)
		条状物图片.scale.x = 计算填充比例 * 条状物最大缩放x
		记录罪恶值 = 获取罪恶值
		记录罪恶值最大 = 获取罪恶值最大
		
		if 记录罪恶值 < 记录左区间1 or 记录罪恶值 > 记录右区间1:
			条状物图片.modulate = Color(1.0, 1.0, 1.0)
		elif 记录罪恶值 < 记录左区间2 or 记录罪恶值 > 记录右区间2:
			条状物图片.modulate = Color(1.0, 0.682, 0.478, 1.0)
		else:
			条状物图片.modulate = Color(1.0, 0.376, 0.322)

func 获取罪恶值区间值() -> void:
	记录左区间1 = 全局数据_系统.当前游玩角色状态机模块实例.罪恶值左区间1
	记录左区间2 = 全局数据_系统.当前游玩角色状态机模块实例.罪恶值左区间2
	记录右区间2 = 全局数据_系统.当前游玩角色状态机模块实例.罪恶值右区间2
	记录右区间1 = 全局数据_系统.当前游玩角色状态机模块实例.罪恶值右区间1
	
	记录罪恶值最大 = 全局数据_系统.当前游玩角色状态机模块实例.罪恶值最大
	左区间1图片.position.x = floor(记录左区间1 / 记录罪恶值最大 * 区间图片最大移动x + 区间图片最小x)
	左区间2图片.position.x = floor(记录左区间2 / 记录罪恶值最大 * 区间图片最大移动x + 区间图片最小x)
	右区间2图片.position.x = ceil(记录右区间2 / 记录罪恶值最大 * 区间图片最大移动x + 区间图片最小x)
	右区间1图片.position.x = ceil(记录右区间1 / 记录罪恶值最大 * 区间图片最大移动x + 区间图片最小x)
	
	更新条状物(true)
