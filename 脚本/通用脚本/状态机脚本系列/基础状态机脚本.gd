extends Node

class_name 基础状态机脚本

var 主节点 : Node = null
var 对象内容节点 : Node = null
var 动画模块 : Node = null

var 主节点首次落地 : bool = false
var 主节点首次探测结果  = null

var 连接点字典 : Dictionary = {}

#region 移动跳跃变量
var 水平加速 : float = 1000
var 水平最大移动 : float = 100
var 水平减速 : float = 1000
var 垂直加速 : float = 2000
var 垂直最大移动 : float = 200
var 垂直减速 : float = 2000
var 起始跳跃速度 : float = 200
var 重力影响系数 : float = 1
var 重力最大移动 : float = 5000
#endregion

var 道具持有数据 : Dictionary
var 全局动态变量字典 : Dictionary
var 道具静态特殊变量数据库 : Dictionary
var 动态变量字典 : Dictionary = {}
#不可能把所有的特殊的道具或者技能的相关变量都声明一遍，所以留一个字典，有需要就往里面加
#如果是自身的变量，对象可以直接处理，这样在波次结束后切换场景，反正对象消失了就不需要考虑后续，下一波又重新生成
#涉及到全局变量的变化，有时需要交给地图基础模块处理，但绝对不能交给全局脚本处理，全局脚本是always，没法正常处理有倒计时类型的效果
#全局变量的临时变化，如果需要在波次结束时处理，则在地图基础模块的接口统一处理

func _ready() ->void:
	主节点 = self.owner
	对象内容节点 = 主节点.get_node("对象内容节点")
	if 主节点.has_node("动画模块"):
		动画模块 = 主节点.get_node("动画模块")
	if 对象内容节点.has_node("连接点集合"):
		var 连接点集合 = 对象内容节点.get_node("连接点集合")
		for 遍历节点 in 连接点集合.get_children():
			连接点字典[遍历节点.name] = 遍历节点
	
	道具持有数据 = 全局数据_周期对局.道具持有数据
	全局动态变量字典 = 全局数据_周期波次.道具动态特殊变量字典
	道具静态特殊变量数据库 = 全局数据库.道具静态特殊变量数据库

func 主节点图块碰撞判断(图块分组 : String = "图块_基础墙体") -> bool:
	for 索引 in 主节点.get_slide_collision_count():
		var 碰撞信息 = 主节点.get_slide_collision(索引)
		var 碰撞体 = 碰撞信息.get_collider()
		if is_instance_valid(碰撞体):
			if 碰撞体 is TileMapLayer:
				#直接使用分组判断，这在所有节点类型（包括 TileMapLayer）上都通用
				if 碰撞体.is_in_group(图块分组):
					return true
	return false

func 主节点落地判断() -> bool:
	
	return 主节点.is_on_floor()
	
	#if 主节点 is CharacterBody2D:
		#if 主节点首次落地 == true:
			#return 主节点.is_on_floor()
		#else:
			#if 主节点首次探测结果 == null:
				#if 主节点.test_move(主节点.transform, Vector2(0, 1.0)):
					#主节点首次探测结果 = true
				#else:
					#主节点首次探测结果 = false
			#return 主节点首次探测结果
	#return false

func 隔帧检测_ID异步(间隔帧数 : int = 10) -> bool:
	return (Engine.get_frames_drawn() + get_instance_id()) % 间隔帧数 == 0

#region 加减速方法，只选择一个
func 默认加速处理(步进时间 : float) -> void:
	var 方向 = 1 if 对象内容节点.scale.x > 0 else -1
	var 目标速度 = 水平最大移动 * 方向
	var 应用加减速度 = 水平加速
	# 使用 abs() 比较绝对值，这样可以同时处理左右两个方向
	if abs(主节点.velocity.x) > abs(目标速度) and sign(主节点.velocity.x) == sign(目标速度):
		# 超速了（且运动方向与目标速度方向一致），使用减速数值
		应用加减速度 = 水平减速
	主节点.velocity.x = move_toward(主节点.velocity.x, 目标速度, 应用加减速度 * 步进时间)

func 默认减速处理(步进时间 : float) -> void:
	主节点.velocity.x = move_toward(主节点.velocity.x, 0, 水平减速 * 步进时间)
#endregion

#region 特殊垂直加减速方法，使用这个时一般禁用重力处理
func 垂直默认加速处理(步进时间 : float) -> void:
	主节点.velocity.y = move_toward(主节点.velocity.x, 垂直最大移动, 垂直加速 * 步进时间)

func 垂直默认减速处理(步进时间 : float) -> void:
	主节点.velocity.y = move_toward(主节点.velocity.y, 0, 垂直减速 * 步进时间)
#endregion

func 跳跃处理() -> void:
#该方法不需要传入步进时间，一般用于进入跳跃动作时使用一次
	主节点.velocity.y = 起始跳跃速度 * -1

func 垂直速度修改(修改比率 : float) -> void:
	主节点.velocity.y *= 修改比率

func 重力处理(步进时间 : float) -> void:
	主节点.velocity.y = move_toward(主节点.velocity.y, 重力最大移动, 全局数据_系统.重力加速度 * 重力影响系数 * 步进时间)

func 移动处理() -> void:
	主节点.move_and_slide()

func 对象生成普通特效(生成对象资源名称 : String, 使用连接点名称 : String = "特效连接点") -> Node:
	#动画轨道无法调用全局方法，所以需要自身的方法进行转接
	var 生成对象 = 全局方法.生成普通对象_自由版(生成对象资源名称, 连接点字典[使用连接点名称].global_position, 全局数据_系统.当前场景实体层实例)
	return 生成对象

func 对象生成对象池特效(生成对象资源名称 : String, 使用连接点名称 : String = "特效连接点") -> Node:
	var 生成对象 = 全局方法.生成对象池特效(生成对象资源名称, 连接点字典[使用连接点名称].global_position)
	return 生成对象

func 对象播放普通音频(播放音频名称 : String, 播放冷却时间 : float = 0, 播放音量 : float = 0.0) -> void:
	全局方法.播放音频(播放音频名称, 播放冷却时间, 播放音量, "音效")

func 创建动态变量计时器(计时器名称 : String, 时长 : float, 时长处理方式 : int = 1, 回调函数 : Callable = Callable()):
	var 目标计时器: Timer
	# 1. 仅在不存在时进行“重型”初始化
	if not 动态变量字典.has(计时器名称) or not is_instance_valid(动态变量字典[计时器名称]):
		目标计时器 = Timer.new()
		目标计时器.one_shot = true
		目标计时器.name = 计时器名称
		self.add_child(目标计时器)
		# 仅在此处绑定一次回调，后续重置不再改动逻辑
		if not 回调函数.is_null():
			目标计时器.timeout.connect(回调函数)
		动态变量字典[计时器名称] = 目标计时器
	else:
		目标计时器 = 动态变量字典[计时器名称]
	# 2. 直接启动（如果正在运行，start 会自动重置时间并重新计时）
	match 时长处理方式:
		1:
			目标计时器.start(时长)
		2:
			目标计时器.start(目标计时器.time_left + 时长)
