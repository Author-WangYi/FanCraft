extends 基础状态机脚本_可攻击类

class_name 基础状态机脚本_敌人投射物

func _ready() ->void:
	super()
	接口_生成时()

func 生成时变量同步() -> void:
	pass

func 检测到受伤区域进入(来源区域 : Area2D) -> void:
	super(来源区域)

func 检测到攻击区域进入(_来源区域 : Area2D) -> void:
	主节点.queue_free()

#region 常规接口  用于处理道具的特殊效果
func 接口_生成时() -> void:
	pass

func 状态接口_进入技能时(状态名 : String) -> void:  #开始技能的第一段动画的一帧执行(比如有的道具根据释放技能次数给效果)
	状态接口_持续技能时(状态名)
	pass
func 状态接口_持续技能时(_状态名 : String) -> void:  #开始技能的每一段动画的一帧执行(道具给技能加伤，但有的技能是分段状态的，开启新的一段后数据全都刷新了，需要再执行一次)
	pass
#endregion
