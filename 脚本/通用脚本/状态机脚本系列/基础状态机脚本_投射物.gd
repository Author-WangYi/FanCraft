extends 基础状态机脚本_可攻击类

class_name 基础状态机脚本_投射物

@export var 当前技能生命窃取次数 : float = 0
@export var 当前技能命中获得能量合计 : float = 0

func _ready() ->void:
	super()
	接口_生成时()

func 跟随上层对象(步进时间 : float, 移动速度 : float = 1, 坐标偏移 : Vector2 = Vector2(0, 0)) -> void:
	if not is_instance_valid(上层状态机模块): 
		return
	var 实际偏移 : Vector2 = 坐标偏移
	if 上层状态机模块.对象内容节点.scale.x < 0:
		实际偏移.x = -实际偏移.x
	var 目标坐标 = 上层状态机模块.主节点.global_position + 实际偏移
	主节点.global_position = 主节点.global_position.move_toward(目标坐标, 移动速度 * 步进时间)

func 检测到受伤区域进入(来源区域 : Area2D) -> void:
	super(来源区域)
	if 当前技能生命窃取次数 > 0:
		var 生命窃取属性值 = 全局数据_周期对局.玩家属性_生命窃取
		if 生命窃取属性值 > 0:
			var 计算恢复值 = 0
			var 生命窃取每阶段值 = 全局数据_环境.生命窃取每阶段值
			var 生命窃取每阶段恢复概率值 = 全局数据_环境.生命窃取每阶段恢复概率值
			while 生命窃取属性值 > 0:
				var 本阶段生命窃取属性值 = min(生命窃取每阶段值, 生命窃取属性值)
				var 本阶段恢复概率值 = 本阶段生命窃取属性值 / 生命窃取每阶段值 * 生命窃取每阶段恢复概率值
				var 随机数 = randf()
				if 随机数 <= 本阶段恢复概率值:
					计算恢复值 += 1
				生命窃取属性值 -= 生命窃取每阶段值
			上层状态机模块.生命值 = min(上层状态机模块.生命值 + 计算恢复值, 上层状态机模块.生命值最大)
		当前技能生命窃取次数 -= 1
	
	if 当前技能命中获得能量合计 > 0:
		上层状态机模块.能量 = min(上层状态机模块.能量 + 1, 上层状态机模块.能量最大)
		当前技能命中获得能量合计 -= 1

func 与上层对象的距离检测(指定距离 : float = 0, 检测方式 : int = 1) -> bool:
	#1-小于等于指定距离，2-大于等于指定距离
	if not is_instance_valid(上层状态机模块):
		return false
	var 计算距离 : float = 上层状态机模块.主节点.global_position.x - 主节点.global_position.x
	if 检测方式 == 1:
		return abs(计算距离) <= 指定距离
	if 检测方式 == 2:
		return abs(计算距离) >= 指定距离
	return false

func 生成时变量同步() -> void:
	pass

#region 常规接口  用于处理道具的特殊效果
func 接口_生成时() -> void:
	pass

func 状态接口_进入技能时(状态名 : String) -> void:  #开始技能的第一段动画的一帧执行(比如有的道具根据释放技能次数给效果)
	状态接口_持续技能时(状态名)
	pass
func 状态接口_持续技能时(_状态名 : String) -> void:  #开始技能的每一段动画的一帧执行(道具给技能加伤，但有的技能是分段状态的，开启新的一段后数据全都刷新了，需要再执行一次)
	if 87 in 道具持有数据:
		if 上层状态机模块.技能卡组列表.size() > 0:
			var 计算伤害比例 = 上层状态机模块.技能卡组列表.size() * 道具静态特殊变量数据库["道具87_伤害加成比例值"] + 1
			当前技能基础伤害 *= 计算伤害比例
			当前技能物理伤害 *= 计算伤害比例
			当前技能魔法伤害 *= 计算伤害比例
#endregion
