extends 基础状态机脚本_掉落物类

var 金币数值 = 1
var 移动倒计时 : float = 1

func _ready() ->void:
	super()
	重力影响系数 = 5
	水平加速 = 3600
	水平最大移动 = randf_range(-60, 60)
	水平减速 = 3600
	起始跳跃速度 = 150
	跳跃处理()

func _physics_process(步进时间 : float) -> void:
	if 隔帧检测_ID异步(5):
		if is_instance_valid(全局数据_系统.当前游玩角色实例):
			var 距离平方 = 主节点.global_position.distance_squared_to(全局数据_系统.当前游玩角色实例.global_position)
			if 距离平方 < 256:
				执行拾取()
	if 移动倒计时 > 0:
		移动倒计时 -= 步进时间
		if 主节点图块碰撞判断("图块_基础墙体"):
			移动倒计时 = 0
		else:
			默认加速处理(步进时间)
			重力处理(步进时间)
			移动处理()

func 执行拾取() -> void:
	全局方法.修改玩家属性值("金钱数", 2, 金币数值)
	全局方法.修改玩家属性值("经验值", 2, 金币数值)
	全局方法.播放音频("基础音效_拾取")
	接口_被拾取时()
	主节点.queue_free()
