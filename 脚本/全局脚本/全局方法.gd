extends Node

signal 输入设备更换
@warning_ignore("unused_signal")
signal 玩家角色实例就绪  #由玩家角色对象发送
@warning_ignore("unused_signal")
signal 当前波次已结束

signal 商店相关属性更新

var 场景管理器实例 : Node = null
var 当前摄像机实例 : Node = null
var UI输入倒计时 : Timer = null
var 角色输入倒计时 : Timer = null
var 当前输入设备 : int = 1  #1-键盘，2-手机手柄

var 存档数据分组 : Dictionary

# 存储计算出来的分辨率列表：[Vector2i(640, 360), Vector2i(1280, 720), ...]
var 可选分辨率列表 : Array = []
var 当前显示模式索引 : int = 0
var 基础宽度 : int = 640
var 基础高度 : int = 360
var 鼠标当前可见 : bool = true

var 当前背景音乐系列 : int = 0
var 空闲播放器组 : Array = []
var 循环音频播放器组 : Array = []
var 系列背景音乐播放器 : AudioStreamPlayer
var 系列背景音乐播放器补间: Tween

var 特效对象池 : Dictionary = {}
var 特效对象池索引 : Dictionary = {}
var 特效对象池容量 : Dictionary = {}
var 特效对象池资源 : Dictionary = {}

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	生成分辨率列表()
	当前显示模式索引 = 可选分辨率列表.size()
	应用全屏()  #游戏默认是全屏开始
	切换鼠标状态(false)
	
	存档数据分组 = {"全局数据_周期对局": 全局数据_周期对局, "全局数据_游玩进度": 全局数据_游玩进度}
	
	系列背景音乐播放器 = AudioStreamPlayer.new()
	系列背景音乐播放器.bus = "背景音乐"
	self.add_child(系列背景音乐播放器)
	系列背景音乐播放器.finished.connect(播放系列背景音乐)
	
	#定义一下各种特效的最大显示数量
	特效对象池初始化("特效_命中1", 20)
	特效对象池初始化("特效_命中2", 2)
	特效对象池初始化("特效_伤害数值", 20)
	特效对象池初始化("特效_白色椭圆特效", 6)
	
	UI输入倒计时 = get_node("/root/主场景/UI输入倒计时")
	角色输入倒计时 = get_node("/root/主场景/角色输入倒计时")
	UI输入倒计时.timeout.connect(UI输入倒计时结束)
	角色输入倒计时.timeout.connect(角色输入倒计时结束)

func _input(事件) -> void:
	if 全局数据_系统.UI输入许可:
		if 事件.is_action_pressed("菜单1"):
			if (全局数据_系统.是否禁用打开菜单界面 == false and 全局数据_系统.菜单界面已打开 == false and
			全局数据_系统.背包界面已打开 == false and 全局数据_系统.奖励界面已打开 == false):
				打开菜单界面(2)
		if 事件.is_action_pressed("菜单2"):
			if (全局数据_系统.是否禁用打开背包界面 == false and 全局数据_系统.背包界面已打开 == false and 
			全局数据_系统.菜单界面已打开 == false):
				打开背包界面()
			elif (全局数据_系统.是否禁用打开技能界面 == false and 全局数据_系统.背包界面已打开 == false and
			全局数据_系统.菜单界面已打开 == false):
				打开技能界面(1)
	
	if 事件.is_action_pressed("显示模式切换"):
		显示模式切换()
	# 1. 检测鼠标移动或点击（显示光标）
	if 事件 is InputEventMouseMotion or 事件 is InputEventMouseButton:
		if not 鼠标当前可见:
			切换鼠标状态(true)
	# 2. 检测键盘按键（隐藏光标）
	elif 事件 is InputEventKey:
		# 只有在按下时触发，避免弹起按键也重复执行逻辑
		if 事件.pressed and 鼠标当前可见:
			切换鼠标状态(false)
	# 3. 检测手柄按键或摇杆（隐藏光标）
	elif 事件 is InputEventJoypadButton or 事件 is InputEventJoypadMotion:
		# 只有当手柄摇杆偏移量较大时才触发（防止手柄漂移导致光标一直隐藏）
		if 事件 is InputEventJoypadMotion:
			if abs(事件.axis_value) > 0.5 and 鼠标当前可见:
				切换鼠标状态(false)
		elif 鼠标当前可见:
			切换鼠标状态(false)
	
	var 上次来源 = 当前输入设备
	# 1. 优先检测触摸/手柄（这些在移动端是绝对来源）
	if 事件 is InputEventJoypadButton or 事件 is InputEventJoypadMotion:
		当前输入设备 = 2
	elif 事件 is InputEventScreenTouch or 事件 is InputEventScreenDrag:
		当前输入设备 = 2
	# 2. 检测键盘和真正的鼠标
	elif 事件 is InputEventKey or 事件 is InputEventMouseButton or 事件 is InputEventMouseMotion:
		# 关键：检查该事件是否由触摸模拟产生
		# 在 Godot 4 中，模拟事件的 device ID 通常为 -1 或者可以通过 is_emulated() 检查
		var 是模拟事件 = false
		# 严谨检查方式 A：针对移动端模拟
		if "emulated" in 事件 and 事件.emulated:
			是模拟事件 = true
		# 严谨检查方式 B：判断设备 ID（物理鼠标通常 >= 0）
		if 事件.device < 0:
			是模拟事件 = true
		if 是模拟事件:
			当前输入设备 = 2
		else:
			# 只有非模拟的、真实的键盘鼠标操作才切换到 1
			当前输入设备 = 1
	if 上次来源 != 当前输入设备:
		输入设备更换.emit()

func 进行存档() -> void:
	全局数据_游玩进度.游戏存档版本号 = 全局数据_环境.游戏版本号
	var 配置文件 = ConfigFile.new()
	for 模块名 in 存档数据分组:
		var 目标脚本 = 存档数据分组[模块名]
		# 获取脚本中定义的所有属性
		var 属性列表 = 目标脚本.get_script().get_script_property_list()
		for 属性 in 属性列表:
			# 过滤掉引擎内置属性，只保留用户定义的变量
			if 属性.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				var 变量名 = 属性.name
				if 属性.name != "数据初始镜像":
					var 变量值 = 目标脚本.get(变量名)
					# 写入配置：[模块名] -> 变量名 = 值
					配置文件.set_value(模块名, 变量名, 变量值)
	var 错误码 = 配置文件.save(全局数据_环境.存档路径)
	if 错误码 == OK:
		var 真实文件地址 = ProjectSettings.globalize_path(全局数据_环境.存档路径)
		真实文件地址 = 真实文件地址.replace("/", "\\") 
		print("【全局方法】存档成功：", 真实文件地址)
	else:
		push_error("【全局方法】存档失败，错误码：", 错误码)

func 读取存档() -> void:
	var 配置文件 = ConfigFile.new()
	var 错误码 = 配置文件.load(全局数据_环境.存档路径)
	if 错误码 != OK:
		print("【全局方法】未找到存档或读取失败，读取中断。")
		return
	for 模块名 in 存档数据分组:
		var 目标脚本 = 存档数据分组[模块名]
		# 获取该模块下所有的 Key
		if 配置文件.has_section(模块名):
			for 变量名 in 配置文件.get_section_keys(模块名):
				var 存入值 = 配置文件.get_value(模块名, 变量名)
				# 严谨赋值：将读取到的值塞回全局脚本
				目标脚本.set(变量名, 存入值)
	
	print("【存档中心】读档完成。")

func 修改玩家属性值(属性名称 : String, 运算方式 : int = 1, 数值 = 0) -> void:
	#1-等于，2-加，3-减
	var 处理后数值 = 数值
	var 计算结果 : float = 0
	match 属性名称:
		"经验值":
			处理后数值 *= max(0, 1 + 全局数据_周期对局.额外属性_经验值修改增幅)
	match 运算方式:
		1:
			计算结果 = 处理后数值
		2:
			计算结果 = 全局数据_周期对局.get(属性名称) + 处理后数值
		3:
			计算结果 = 全局数据_周期对局.get(属性名称) - 处理后数值
	match 属性名称:
		"玩家属性_等级":
			计算结果 = max(1, 计算结果)
	全局数据_周期对局.set(属性名称, 计算结果)
	match 属性名称:
		"额外属性_商店物品价格倍率", "额外属性_商店刷新价格倍率", "额外属性_商店免费刷新次数":
			商店相关属性更新.emit()

func 特效对象池初始化(对象资源名称 : String, 容量 : int) -> void:
	特效对象池索引[对象资源名称] = 0
	特效对象池容量[对象资源名称] = 容量
	特效对象池资源[对象资源名称] = 全局数据库.普通对象资源预加载数据库[对象资源名称]

func 生成普通对象(对象资源名称 : String, 坐标 : Vector2,
父节点 : Node, 生成时方向 : float = 1,
指定上层状态机模块 : Node = null, 指定初始状态 : String = "",
是否预加载 : bool = true) -> Node:  #用于投射物，但如果指定复杂的初始变量的话需要使用自由改进版
	if not is_instance_valid(父节点):
		print("【生成普通对象】父节点不存在或已被销毁，操作已跳过")
		return
	var 对象资源
	if 是否预加载 == true:
		对象资源 = 全局数据库.普通对象资源预加载数据库[对象资源名称]
	else:
		对象资源 = load(全局数据库.普通对象资源数据库[对象资源名称])
	var 生成对象 = 对象资源.instantiate()
	生成对象.global_position = 坐标
	var 生成对象的状态机模块 = 生成对象.get_node("状态机模块")
	if 指定上层状态机模块 != null:
		生成对象的状态机模块.上层状态机模块 = 指定上层状态机模块
	if 生成对象.has_node("对象内容节点"):
		生成对象.get_node("对象内容节点").scale.x = 生成时方向
	if 指定初始状态 != "":
		生成对象的状态机模块.指定对象初始状态 = 指定初始状态
	父节点.add_child(生成对象)
	return 生成对象的状态机模块

func 生成普通对象_自由版(对象资源名称 : String, 坐标 : Vector2,
父节点 : Node, 是否预加载 : bool = true) -> Node:  #用于轻量的特效对象
	if not is_instance_valid(父节点):
		print("【生成普通对象_自由版】父节点不存在或已被销毁，操作已跳过")
		return
	var 对象资源
	if 是否预加载 == true:
		对象资源 = 全局数据库.普通对象资源预加载数据库[对象资源名称]
	else:
		对象资源 = load(全局数据库.普通对象资源数据库[对象资源名称])
	var 生成对象 = 对象资源.instantiate()
	生成对象.global_position = 坐标
	父节点.add_child(生成对象)
	return 生成对象

func 生成普通对象_自由改进版(对象资源名称 : String, 是否预加载 : bool = true) -> Node:
	var 对象资源
	if 是否预加载 == true:
		对象资源 = 全局数据库.普通对象资源预加载数据库[对象资源名称]
	else:
		对象资源 = load(全局数据库.普通对象资源数据库[对象资源名称])
	var 生成对象 = 对象资源.instantiate()
	return 生成对象

func 生成对象池特效(对象资源名称 : String, 坐标 : Vector2) -> Node:
	#只适用于简单的，经常使用的纯动画特效
	#这些对象的结束逻辑不是释放而是设为不可见，切换场景时要清空一次
	var 对象资源 = 特效对象池资源.get(对象资源名称, null)
	if 对象资源 == null:
		print("【生成对象池特效】对象池内未登记：", 对象资源名称)
		return
	
	var 该特效对象池列表 = 特效对象池.get(对象资源名称, [])
	var 使用对象
	if 该特效对象池列表.size() < 特效对象池容量[对象资源名称]:
		特效对象池索引[对象资源名称] = 该特效对象池列表.size()
		使用对象 = 对象资源.instantiate()
		特效对象池[对象资源名称] = 该特效对象池列表
		特效对象池[对象资源名称].append(使用对象)
		使用对象.global_position = 坐标
		使用对象.visible = true
		全局数据_系统.当前场景实体层实例.add_child(使用对象)
	else:
		使用对象 = 特效对象池[对象资源名称][特效对象池索引[对象资源名称]]
		使用对象.global_position = 坐标
		使用对象.visible = true
	特效对象池索引[对象资源名称] += 1
	if 特效对象池索引[对象资源名称] == 特效对象池容量[对象资源名称]:
		特效对象池索引[对象资源名称] = 0
	return 使用对象

func 生成伤害数值特效(数值内容, 坐标 : Vector2) -> Node:
	var 生成对象 = 生成对象池特效("特效_伤害数值", 坐标)
	生成对象.数值显示.text = str(int(数值内容))
	return 生成对象

func 导入角色初始数据(角色编号) -> void:
	角色编号 = int(角色编号)
	var 当前角色数据 = 全局数据库.角色数据库[角色编号]
	全局方法.重置全局数据_周期对局()
	全局数据_周期对局.当前角色编号 = 角色编号
	全局方法.将字典赋值给对象(全局数据_周期对局, 当前角色数据)
	
	var 当前角色初始道具数据 = 全局数据库.角色初始道具数据库[角色编号]
	var 当前角色初始技能数据 = 全局数据库.角色初始技能数据库[角色编号]
	
	var 遍历数 = 1
	while 遍历数 < 999:
		var 拼接道具编号键名 = "道具编号%d" % 遍历数
		var 拼接道具数量键名 = "道具数量%d" % 遍历数
		if int(当前角色初始道具数据.get(拼接道具编号键名, 0)) > 0:
			物品获得处理(当前角色初始道具数据[拼接道具编号键名], 1, 当前角色初始道具数据[拼接道具数量键名], true)
		else:
			break
		遍历数 += 1
	
	遍历数 = 1
	while 遍历数 < 999:
		var 拼接技能编号键名 = "技能编号%d" % 遍历数
		var 拼接技能数量键名 = "技能数量%d" % 遍历数
		if int(当前角色初始技能数据.get(拼接技能编号键名, 0)) > 0:
			物品获得处理(当前角色初始技能数据[拼接技能编号键名], 2, 当前角色初始技能数据[拼接技能数量键名], true)
		else:
			break
		遍历数 += 1
	
	var 键位数量 = 全局数据_周期对局.技能编号_键位.size()
	for 键位遍历 in range(键位数量):
		var 拼接键位技能编号键名 = "技能编号_键位组合%d" % 键位遍历
		if int(当前角色初始技能数据.get(拼接键位技能编号键名, 0)) > 0:
			全局数据_周期对局.技能编号_键位[键位遍历] = 当前角色初始技能数据[拼接键位技能编号键名]

func 构建次级索引(输出索引字典 : Dictionary, 属性名 : String, 来源数据库 : Dictionary, 输出为字典 : bool = false) -> void:
	输出索引字典.clear()
	for 键 in 来源数据库:
		var 条目数据 = 来源数据库[键]
		for 具体的属性名 in 条目数据.keys():
			if 具体的属性名.begins_with(属性名):
				var 属性值 = 条目数据[具体的属性名]
				if 属性值 == null or str(属性值) == "":
					continue
				if not 输出索引字典.has(属性值):
					if 输出为字典:
						输出索引字典[属性值] = {}
					else:
						输出索引字典[属性值] = []
				if 输出为字典:
					输出索引字典[属性值][键] = true 
				else:
					输出索引字典[属性值].append(键)
	if not 输出为字典:
		for 分类键 in 输出索引字典:
			输出索引字典[分类键].sort()

func 构建概率数字典(输出字典 : Dictionary, 属性名 : String, 来源数据 : Dictionary) -> float:
	var 遍历数 : int = 1
	var 概率数总和 : float = 0
	while true:
		var 拼接属性名 = 属性名 + str(遍历数)
		if not 来源数据.has(拼接属性名):
			return 概率数总和
		输出字典[遍历数] = 来源数据[拼接属性名]
		概率数总和 += 来源数据[拼接属性名]
		遍历数 += 1
	return 概率数总和

func 物品获得处理(物品编号, 物品类型, 物品数量 : int = 1, 禁用接口 : bool = false) -> void:
	#角色获得初始道具时要禁用接口，防止触发获得时效果，平时不会用到
	物品编号 = int(物品编号)
	物品类型 = int(物品类型)  #1-道具，2-技能
	物品数量 = int(物品数量)
	if 物品数量 > 1:
		for 循环 in range(物品数量):
			物品获得处理(物品编号, 物品类型, 1, 禁用接口)
	else:
		match 物品类型:
			1:
				var 获得前接口结果 = true
				if 禁用接口 == false:
					获得前接口结果 = 接口_道具获得前(物品编号)
				#如果返回false，则说明停止接下来的获得流程
				if 获得前接口结果 == true:
					if 全局数据_周期对局.道具持有数据.has(物品编号):
						全局数据_周期对局.道具持有数据[物品编号] += 1
					else:
						全局数据_周期对局.背包总栏数 += 1
						全局数据_周期对局.背包存储数据[全局数据_周期对局.背包总栏数] = 物品编号
						全局数据_周期对局.道具持有数据[物品编号] = 物品数量
					将字典赋值给对象(全局数据_周期对局, 全局数据库.道具数据库[物品编号], 1)
					道具合成处理(物品编号)
					接口_道具获得时(物品编号)
			2:
				var 获得前接口结果 = true
				if 禁用接口 == false:
					获得前接口结果 = 接口_技能获得前(物品编号)
				#如果返回false，则说明停止接下来的获得流程
				if 获得前接口结果:
					var 当前角色技能背包类型 = 全局数据库.角色数据库[全局数据_周期对局.当前角色编号]["角色技能背包类型"]
					if 全局数据_周期对局.技能持有数据.has(物品编号):
						if 全局数据_周期对局.技能持有数据[物品编号] == -999:
							pass
						elif 物品数量 == -999:
							全局数据_周期对局.技能持有数据[物品编号] = -999
							if 当前角色技能背包类型 == 2:
								全局数据_周期对局.卡片技能持有数据[物品编号] = -999
						else:
							全局数据_周期对局.技能持有数据[物品编号] += 1
							if 当前角色技能背包类型 == 2:
								全局数据_周期对局.卡片技能持有数据[物品编号] += 1
					else:
						全局数据_周期对局.技能背包总栏数 += 1
						全局数据_周期对局.技能背包存储数据[全局数据_周期对局.技能背包总栏数] = 物品编号
						全局数据_周期对局.技能持有数据[物品编号] = 物品数量
						if 当前角色技能背包类型 == 2:
							全局数据_周期对局.卡片技能持有数据[物品编号] = 物品数量
					接口_技能获得时(物品编号)

func 道具合成处理(道具编号 : int) -> void:
	var 可合成道具编号 = int(全局数据库.道具数据库[道具编号]["作为材料可合成"])
	if 可合成道具编号 == 0:
		return
	var 可合成道具限定数量 = int(全局数据库.道具数据库[可合成道具编号]["道具限定数量"])
	var 可合成道具持有数量 = 全局数据_周期对局.道具持有数据.get(可合成道具编号, 0)
	if 可合成道具限定数量 == 0 or 可合成道具持有数量 < 可合成道具限定数量:
		var 合成材料道具编号列表 = 全局数据库.道具数据库_作为材料可合成次级索引[可合成道具编号]
		for 遍历道具编号 in 合成材料道具编号列表:
			var 作为材料所需数量 = 全局数据库.道具数据库[遍历道具编号]["作为材料所需数量"]
			if 全局数据_周期对局.道具持有数据.get(遍历道具编号, 0) < 作为材料所需数量:
				return
		for 遍历道具编号 in 合成材料道具编号列表:
			var 作为材料所需数量 = 全局数据库.道具数据库[遍历道具编号]["作为材料所需数量"]
			全局数据_周期对局.道具持有数据[遍历道具编号] -= 作为材料所需数量
			var 循环次数 = 作为材料所需数量
			while 循环次数 > 0:
				循环次数 -= 1
				将字典赋值给对象(全局数据_周期对局, 全局数据库.道具数据库[遍历道具编号], 2)
		物品获得处理(可合成道具编号, 1, 1)
		var 生成通知框 = 全局数据库.UI资源预加载数据库["UI_通知框"].instantiate()
		var 通知文本 = "物品合成成功，请打开背包查看\n【" + 全局数据库.道具数据库[可合成道具编号]["道具名称"] + "】"
		生成通知框.显示文本 = 通知文本
		生成通知框.显示时间 = 1.2
		全局数据_系统.当前场景UI层实例.add_child(生成通知框)
		播放音频("基础音效_按键声3")

func UI输入倒计时结束() -> void:
	全局数据_系统.UI输入许可 = true

func 角色输入倒计时结束() -> void:
	全局数据_系统.角色输入许可 = true

func 填充节点列表(节点列表 : Array, 起始索引 : int, 结束索引 : int, 父节点, 前缀名 : String) -> void:
	#自动扫描指定父节点下的命名节点并填入列表
	if 父节点 == null:
		print("【填充节点列表】错误：父节点不存在")
		return
	var 总长度 = 结束索引 + 1
	节点列表.resize(总长度)
	for 序号 in range(起始索引, 结束索引 + 1):
		var 节点名称 = "%s%d" % [前缀名, 序号]
		var 找到的节点 = 父节点.get_node(节点名称)
		var 存储索引 = 序号
		if 找到的节点 != null:
			节点列表[存储索引] = 找到的节点
		else:
			print("警告：未找到节点 ", 节点名称)

func 节点列表连接信号(节点列表 : Array, 信号名 : String, 接收方法) -> void:
	if 节点列表.is_empty():
		print("警告：提供的节点列表为空，无法连接信号")
		return
	for 索引 in range(节点列表.size()):
		var 当前节点 = 节点列表[索引]
		if 当前节点 != null and 当前节点.has_signal(信号名):
			当前节点.connect(信号名, 接收方法.bind(索引))

func 防御力修正伤害(伤害值 : float) -> float:
	var 防御力属性值 = 全局数据_周期对局.玩家属性_防御力
	var 防御力平衡系数 = 全局数据_环境.防御力平衡系数
	var 计算伤害值 = 伤害值
	if 防御力属性值 > 0:
		计算伤害值 = (防御力平衡系数 / (防御力属性值 + 防御力平衡系数)) * 伤害值
	elif 防御力属性值 < 0:
		计算伤害值 = ((防御力平衡系数 / (防御力属性值 - 防御力平衡系数)) + 2) * 伤害值
	return 计算伤害值

func 开始下一波次(是否读档 : bool = false) -> void:
	if 是否读档 == false:
		全局数据_周期对局.当前波次 = 全局数据_周期对局.下一波次
		全局数据_周期对局.下一波次 += 1
		全局数据_周期对局.当前对局进行中 = 1
		var 随机地图编号 = 全局数据库.地图数据库.keys().pick_random()
		全局数据_周期对局.当前地图编号 = 随机地图编号
	重置全局数据_周期波次()
	进行存档()
	切换场景(全局数据库.地图数据库[全局数据_周期对局.当前地图编号]["对象资源名称"])

func 游戏结束() -> void:
	重置全局数据_周期对局()
	进行存档()
	get_tree().paused = true
	全局数据_系统.是否禁用打开背包界面 = true
	全局数据_系统.是否禁用打开技能界面 = true
	全局数据_系统.是否禁用打开菜单界面 = true
	渐进式修改音频总线音量(-80, "背景音乐", 2)
	var 生成游戏结束动画 = 全局数据库.UI资源预加载数据库["UI_游戏结束动画"].instantiate()
	全局数据_系统.当前场景UI层实例.add_child(生成游戏结束动画)

func 切换场景(场景名称 : String, 是否等待通知框 : bool = true,
是否使用黑幕 : bool = false, 缓冲时间 : float = 0, 背景音乐渐进时间 : float = 0.5) -> Node:
	print("【全局方法.切换场景】启动切换场景，目标场景名称：", 场景名称, "，是否等待通知框：", 是否等待通知框, "，是否使用黑幕：", 是否使用黑幕, "，缓冲时间：", 缓冲时间)
	# 1. 尝试从数据库获取路径，增加防崩溃检查
	if not 全局数据库.场景资源预加载数据库.has(场景名称):
		print("错误：数据库中不存在场景键名 -> ", 场景名称)
		return null
	# 附加 -- 过渡界面处理
	if ((是否等待通知框 == true and 全局数据_系统.存在通知未结束数量 > 0) or
	缓冲时间 > 0):
		var 生成过渡界面 = 全局数据库.UI资源预加载数据库["UI_过渡界面"].instantiate()
		生成过渡界面.下一个场景名称 = 场景名称
		生成过渡界面.是否等待通知框 = 是否等待通知框
		生成过渡界面.缓冲时间 = 缓冲时间
		生成过渡界面.get_node("黑幕图片").visible = 是否使用黑幕
		全局数据_系统.当前场景UI层实例.add_child(生成过渡界面)
		return 生成过渡界面
	# 3. 卸载旧场景
	if 场景管理器实例.当前场景 != null:
		场景管理器实例.当前场景.queue_free()
	# 4. 加载资源
	var 场景资源 = 全局数据库.场景资源预加载数据库[场景名称]
	if 场景资源 == null:
		print("错误：无法加载场景资源 -> ", 场景名称)
		return null
	# 5. 实例化并挂载
	全局数据_系统.存在通知未结束数量 = 0
	特效对象池 = {}
	var 新场景实例 = 场景资源.instantiate()
	场景管理器实例.add_child(新场景实例)
	场景管理器实例.当前场景 = 新场景实例
	切换场景背景音乐(场景名称, 背景音乐渐进时间)
	get_tree().paused = false
	全局方法.UI输入倒计时启动()
	return null

func 切换场景背景音乐(场景名称 : String, 背景音乐渐进时间 : float = 0.5) -> void:
	if not 全局数据库.场景数据库.has(场景名称):
		return
	var 场景数据 = 全局数据库.场景数据库[场景名称]
	var 当前场景背景音乐系列 = int(场景数据["背景音乐系列"])
	var 当前场景播放音量调整 = int(场景数据["播放音量调整"])
	
	if 当前场景背景音乐系列 == 0:
		pass
	elif 当前场景背景音乐系列 == -1 or 当前场景背景音乐系列 == 当前背景音乐系列:
		渐进式修改音频总线音量(当前场景播放音量调整, "背景音乐", 背景音乐渐进时间)
	else:
		渐进式修改音频总线音量(当前场景播放音量调整, "背景音乐", 背景音乐渐进时间)
		当前背景音乐系列 = 当前场景背景音乐系列
		播放系列背景音乐()

func 播放系列背景音乐() -> void:
	var 当前系列音乐列表 = 全局数据库.背景音乐数据库_背景音乐系列次级索引[当前背景音乐系列]
	if not 当前系列音乐列表.is_empty():
		var 随机选择音乐编号 = 当前系列音乐列表.pick_random()
		var 背景音乐数据 = 全局数据库.背景音乐数据库[随机选择音乐编号]
		系列背景音乐播放器.volume_db = 背景音乐数据["音乐音量"]
		var 资源 = 全局数据库.音频资源预加载数据库[背景音乐数据["音乐名称"]]
		系列背景音乐播放器.stream = 资源
		系列背景音乐播放器.play()

func 播放音频(音频名称 : String, 播放冷却时间 : float = 0, 音量 : float = 0.0, 播放总线 : String = "音效") ->void:
	if not 全局数据库.音频资源预加载数据库.has(音频名称): 
		return
	if 播放冷却时间 > 0:
		var 计时器名称 = 音频名称 + "倒计时"
		var 计时器 = self.get_node_or_null(计时器名称)
		if 计时器 == null:
			计时器 = Timer.new()
			计时器.name = 计时器名称
			计时器.one_shot = true
			self.add_child(计时器)
		if not 计时器.is_stopped():
			return
		计时器.wait_time = 播放冷却时间
		计时器.start()
	var 播放器实例 = 执行获取播放器()
	播放器实例.bus = 播放总线
	播放器实例.volume_db = 音量
	var 资源 = 全局数据库.音频资源预加载数据库[音频名称]
	音频资源设置循环(资源, false)
	播放器实例.stream = 资源
	# 核心：单次音效必须连接自动回收信号
	# 使用 CONNECT_ONE_SHOT 确保信号触发一次后自动断开，最严谨
	if not 播放器实例.finished.is_connected(执行收回播放器):
		播放器实例.finished.connect(执行收回播放器.bind(播放器实例), CONNECT_ONE_SHOT)
	播放器实例.play()

func 播放循环音频(音频名称 : String, 音量 : float = 0.0, 播放总线 : String = "背景音乐") ->void:
	#基本上是没用了，背景音乐也不用这个功能
	if not 全局数据库.音频资源预加载数据库.has(音频名称): 
		return
	var 播放器实例 = 执行获取播放器()
	播放器实例.bus = 播放总线
	播放器实例.volume_db = 音量
	var 资源 = 全局数据库.音频资源预加载数据库[音频名称]
	音频资源设置循环(资源, true)
	播放器实例.stream = 资源
	循环音频播放器组.append(播放器实例)
	
	播放器实例.play()

func 停止所有循环音频() -> void:
	#基本上是没用了
	for 遍历播放器实例 in 循环音频播放器组:
		if 遍历播放器实例.is_playing():
			遍历播放器实例.stop()
		# 极其重要：在回收前把资源的循环关掉，否则下次从池子里拿出来还会乱跳
		if 遍历播放器实例.stream:
			音频资源设置循环(遍历播放器实例.stream, false)
		执行收回播放器(遍历播放器实例)
	循环音频播放器组.clear()

func 等待获取(变量名 : String, 来源对象, 就绪信号 : Signal):
	var 当前值 = 来源对象.get(变量名)
	if 当前值 == null or not is_instance_valid(当前值):
		await 就绪信号
		当前值 = 来源对象.get(变量名)
	return 当前值

func 修改游戏速度(时长: float = 0.1, 速度比例: float = 0.05) -> void:
	Engine.time_scale = 速度比例
	# 注意：这里必须用 get_tree().create_timer
	# 并且要把 process_always 设为 true，否则计时器也会被“慢放”
	await get_tree().create_timer(时长, true, false, true).timeout
	Engine.time_scale = 1.0

func 屏幕抖动(抖动强度 : float = 4, 抖动时间 : float = 0.1, 启用衰减 : bool = true) -> void:
	if not is_instance_valid(当前摄像机实例):
		return
	当前摄像机实例.抖动强度 = 抖动强度
	当前摄像机实例.抖动倒计时 = 抖动时间
	if 启用衰减:
		当前摄像机实例.衰减速度 = 抖动强度 / 抖动时间

func 渐进式修改音频总线音量(目标音量 : float = 0, 音频总线名称 : String = "背景音乐", 渐进时间 : float = 0.5):
	var 音频总线索引 : int = AudioServer.get_bus_index(音频总线名称)
	if 音频总线索引 == -1:
		return
	if 系列背景音乐播放器补间 and 系列背景音乐播放器补间.is_running():
		系列背景音乐播放器补间.kill()
	系列背景音乐播放器补间 = create_tween()
	var 当前音量 = AudioServer.get_bus_volume_db(音频总线索引)
	系列背景音乐播放器补间.tween_method((func(渐进音量): 修改音频总线音量(渐进音量, 音频总线索引)), 当前音量, 目标音量, 渐进时间)

func 修改音频总线音量(音量数值 : float, 音频总线索引 : int) ->void:
	AudioServer.set_bus_volume_db(音频总线索引, 音量数值)
	AudioServer.set_bus_mute(音频总线索引, 音量数值 <= -79.0)

func 记录数据初始镜像(目标对象, 存储字典: Dictionary) -> void:
	for 属性 in 目标对象.get_script().get_script_property_list():
		# 只处理用户定义的变量
		if 属性.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
			var 名字 = 属性.name
			# 过滤掉存储字典本身
			if 名字 == "数据初始镜像": 
				continue 
			var 值 = 目标对象.get(名字)
			if 值 is Array or 值 is Dictionary:
				存储字典[名字] = 值.duplicate(true)
			elif 值 is PackedInt32Array or 值 is PackedFloat32Array:
				存储字典[名字] = 值.duplicate()
			else:
				存储字典[名字] = 值

func 输出玩家属性名称字符串() -> String:
	var 字符串 = ""
	for 遍历字符串 in 全局数据_环境.玩家属性名称列表:
		字符串 += 遍历字符串
		字符串 += "\n"
	return 字符串

func 输出玩家属性数值字符串() -> String:
	var 字符串 = ""
	for 遍历属性名 in 全局数据_环境.玩家属性名称列表:
		var 原始值 = 全局数据_周期对局.get("玩家属性_" + 遍历属性名)
		var 文本 = str(原始值)
		if 文本.ends_with(".0"):
			文本 = 文本.left(-2)
		var 这一行 = ""
		if 原始值 > 0:
			# 正数：薄荷绿
			这一行 = "[right][color=#72f27a]" + 文本 + "[/color][/right]\n"
		elif 原始值 < 0:
			# 负数：珊瑚红
			这一行 = "[right][color=#ff6b6b]" + 文本 + "[/color][/right]\n"
		else:
			这一行 = "[right]" + 文本 + "[/right]\n"
		字符串 += 这一行
	return 字符串

func 将字典赋值给对象(目标对象, 数据源 : Dictionary, 运算模式 : int = 0, 是否使用默认值 : bool = false, 默认值 = 0) -> void:
	if 目标对象 == null:
		return
	for 变量名 in 数据源:
		var 来源值 = 数据源[变量名]
		if (typeof(来源值) == TYPE_STRING and 来源值 == "") or 来源值 == null:
			if 是否使用默认值:
				来源值 = 默认值
			else:
				continue
		if 运算模式 == 0:
			目标对象.set(变量名, 来源值)
			continue
		var 旧值 = 目标对象.get(变量名)
		if 旧值 == null: 
			continue
		var 新值 = 旧值
		match 运算模式:
			1:
				新值 = 旧值 + 来源值
			2:
				新值 = 旧值 - 来源值
			3:
				新值 = 旧值 * 来源值
			4: 
				if 来源值 != 0: # 严谨：防止除以 0 导致崩溃
					新值 = 旧值 / 来源值
		目标对象.set(变量名, 新值)

func 将字典赋值给字典(目标字典 : Dictionary, 数据源: Dictionary, 运算模式 : int = 0) -> void:
	for 遍历键 in 数据源:
		match 运算模式:
			0:
				目标字典[遍历键] = 数据源[遍历键]
			1:
				目标字典[遍历键] = 目标字典.get(遍历键, 0) + 数据源[遍历键]
			2:
				目标字典[遍历键] = 目标字典.get(遍历键, 0) - 数据源[遍历键]

func 重置全局数据_周期波次() ->void:
	重置全部变量(全局数据_周期波次, 全局数据_周期波次.数据初始镜像)

func 重置全局数据_周期对局() ->void:
	重置全部变量(全局数据_周期对局, 全局数据_周期对局.数据初始镜像)
	重置全部变量(全局数据_周期波次, 全局数据_周期波次.数据初始镜像)

func 重置全局数据_系统() ->void:
	重置全部变量(全局数据_系统, 全局数据_系统.数据初始镜像)

func 打开背包界面() ->void:
	print("打开背包界面")
	全局方法.UI输入倒计时启动()
	var 生成背包界面 = 全局数据库.UI资源预加载数据库["UI_背包界面"].instantiate()
	全局数据_系统.当前场景UI层实例.add_child(生成背包界面)

func 打开技能界面(界面模式扩展 : int = 1) ->void:
	print("打开技能界面")
	全局方法.UI输入倒计时启动()
	var 生成技能界面 = 全局数据库.UI资源预加载数据库["UI_技能界面"].instantiate()
	生成技能界面.界面模式扩展 = 界面模式扩展
	全局数据_系统.当前场景UI层实例.add_child(生成技能界面)

func 打开菜单界面(界面模式扩展 : int = 2) ->void:
	print("打开菜单界面")
	全局方法.UI输入倒计时启动()
	var 生成标题界面 = 全局数据库.UI资源预加载数据库["UI_标题界面"].instantiate()
	生成标题界面.界面模式扩展 = 界面模式扩展
	全局数据_系统.当前场景UI层实例.add_child(生成标题界面)

func UI输入倒计时启动() ->void:
	全局数据_系统.UI输入许可 = false
	UI输入倒计时.start()
	角色输入倒计时启动()

func 角色输入倒计时启动() ->void:
	全局数据_系统.角色输入许可 = false
	角色输入倒计时.start()

func 解析自定义文本(原始文本: String) -> String:
	var 处理后的文本 = 原始文本
	while "/【" in 处理后的文本 and "】/" in 处理后的文本:
		var 左位置 = 处理后的文本.find("/【")
		var 右位置 = 处理后的文本.find("】/")
		var 路径起始 = 左位置 + 2
		var 路径长度 = 右位置 - 路径起始
		var 原始路径 = 处理后的文本.substr(路径起始, 路径长度)
		var 清洗后的路径 = 原始路径.replace("\\\"", "\"")
		var 是否为百分比 = false
		var 正负号指定 = ""
		var 颜色指定 = ""
		
		if 清洗后的路径.begins_with("/%/"):
			是否为百分比 = true
			# 去掉开头的 % 字符，得到真实的数据库路径
			清洗后的路径 = 清洗后的路径.substr(3)
		
		if 清洗后的路径.begins_with("/+/"):
			正负号指定 = "+"
			清洗后的路径 = 清洗后的路径.substr(3)
		elif 清洗后的路径.begins_with("/-/"):
			正负号指定 = "-"
			清洗后的路径 = 清洗后的路径.substr(3)
		
		if 清洗后的路径.begins_with("/绿/"):
			颜色指定 = "[color=#72f27a]"
			清洗后的路径 = 清洗后的路径.substr(3)
		elif 清洗后的路径.begins_with("/红/"):
			颜色指定 = "[color=#ff6b6b]"
			清洗后的路径 = 清洗后的路径.substr(3)
		
		# 获取该路径对应的真实数值
		var 真实数值 = 解析获取路径文本对应值(清洗后的路径)
		var 替换结果: String
		
		if 是否为百分比:
			var 原始百分值 = float(真实数值) * 100
			var 处理后的值 = snapped(原始百分值, 0.01)
			if is_equal_approx(处理后的值, floor(处理后的值)):
				替换结果 = str(int(处理后的值)) + "%"
			else:
				替换结果 = str(处理后的值) + "%"
		else:
			替换结果 = str(真实数值)
		
		if 正负号指定 != "":
			替换结果 = 正负号指定 + 替换结果
		
		if 颜色指定 != "":
			替换结果 = 颜色指定 + 替换结果 + "[/color]"
		
		var 待替换目标 = "/【" + 原始路径 + "】/"
		处理后的文本 = 处理后的文本.replace(待替换目标, 替换结果)
	return 处理后的文本

func 生成道具描述文本(输入ID) -> String:
	var 道具编号 : int = int(输入ID)
	var 原始数据 = 全局数据库.道具数据库.get(道具编号)
	if 原始数据 == null: 
		return "未知道具(ID:" + str(道具编号) + ")"
	var 最终文本 = ""
	# --- 附加：合成配方 ---
	if 道具编号 in 全局数据库.道具数据库_作为材料可合成次级索引:
		var 合成配方文本 = "(材料:"
		var 首个材料文本 : bool = true
		for 遍历材料道具编号 in 全局数据库.道具数据库_作为材料可合成次级索引[道具编号]:
			var 材料道具名称 = 全局数据库.道具数据库[遍历材料道具编号]["道具名称"]
			var 材料道具所需数量 = 全局数据库.道具数据库[遍历材料道具编号]["作为材料所需数量"]
			if 首个材料文本 == true:
				首个材料文本 = false
			else:
				合成配方文本 += "+"
			合成配方文本 += "[" + 材料道具名称 + "]" + "*" + str(材料道具所需数量)
		最终文本 += 合成配方文本 + ")\n"
	# --- 第一段：限定数量与持有情况 ---
	var 持有量 = 全局数据_周期对局.道具持有数据.get(道具编号, 0)
	var 限定量 = 原始数据.get("道具限定数量")
	if str(限定量) != "":
		最终文本 += "(限定" + str(持有量) + "/" + str(限定量) + ")\n"
	# --- 第二段：合成信息 ---
	var 合成目标ID = 原始数据.get("作为材料可合成")
	if str(合成目标ID) != "":
		var 目标ID_整型 = int(合成目标ID)
		if 全局数据库.道具数据库.has(目标ID_整型):
			var 合成名称 = 全局数据库.道具数据库[目标ID_整型]["道具名称"]
			最终文本 += "可合成[" + 合成名称 + "]\n"
	# --- 第三段：特殊注释（解析动态路径） ---
	var 特殊注释 = 原始数据.get("特殊注释", "")
	if 特殊注释 != "":
		最终文本 += 解析自定义文本(特殊注释) + "\n" + "\n"
	# --- 第四段：属性增减（局部着色与排序） ---
	var 正值列表 = []
	var 负值列表 = []
	# 遍历全局环境定义的属性名称列表
	for 属性名 in 全局数据_环境.玩家属性名称列表:
		# 构造 JSON 中的完整键名，例如 "玩家属性_最大生命值"
		var 数据库键名 = "玩家属性_" + 属性名
		var 原始值 = 原始数据.get(数据库键名)
		# 严谨处理空值和 0
		if str(原始值) == "" or 原始值 == null:
			continue
		var 数值 = float(原始值)
		if 数值 == 0:
			continue
		# 格式化数值文本（去掉 .0）
		var 格式化数值 = str(数值)
		if 格式化数值.ends_with(".0"):
			格式化数值 = 格式化数值.left(-2)
		# 仅对数值部分进行变色
		if 数值 > 0:
			# [color]只包裹符号和数字，属性名放在外面
			var 行 = "[color=#72f27a]+" + 格式化数值 + "[/color] " + 属性名
			正值列表.append(行)
		else:
			# 负号已经包含在格式化数值里了（例如 "-1"）
			var 行 = "[color=#ff6b6b]" + 格式化数值 + "[/color] " + 属性名
			负值列表.append(行)
	# 合并输出：正值在上，负值在下
	for 行 in 正值列表: 最终文本 += 行 + "\n"
	for 行 in 负值列表: 最终文本 += 行 + "\n"
	return 最终文本.rstrip("\n")

func 生成技能描述文本(输入ID) -> String:
	# 1. 获取基础数据
	var 当前角色名称 = 全局数据库.角色数据库[全局数据_周期对局.当前角色编号]["角色名称"]
	var 拼接技能数据库键名 = "技能数据库_" + 当前角色名称
	var 当前角色技能数据库 = 全局数据库.技能数据库[拼接技能数据库键名]
	var 技能编号 : int = int(输入ID)
	var 技能数据 = 当前角色技能数据库.get(技能编号, {})
	if 技能数据.is_empty():
		return "生成技能描述文本时获取到空技能数据"
	var 最终描述 = ""
	# 2. 构造头部：键位信息
	var 当前角色技能角色技能背包类型 = 全局数据库.角色数据库[全局数据_周期对局.当前角色编号]["角色技能背包类型"]
	var 键位名称字典 : Dictionary
	match 当前角色技能角色技能背包类型:
		1:
			键位名称字典 = 全局数据_环境.键位名称字典1
		2:
			键位名称字典 = 全局数据_环境.键位名称字典1
		3:
			键位名称字典 = 全局数据_环境.键位名称字典3
	var 遍历技能键位属性 : int = 1
	var 写入键位信息 : bool = false
	while true:
		var 拼接属性名 = "技能键位%d" % 遍历技能键位属性
		var 键位编号 : int = int(技能数据.get(拼接属性名, 0))
		if 键位编号 != 0:
			var 键位名 = 键位名称字典.get(键位编号, "未知键位")
			if 写入键位信息 == false:
				写入键位信息 = true
				最终描述 += "(键位:"
			else:
				最终描述 += "/"
			最终描述 += 键位名
		else:
			break
		遍历技能键位属性 += 1
	if 写入键位信息 == true:
		最终描述 += ")\n"
	# 3. 构造中部：冷却时间
	var 冷却 = 技能数据.get("冷却时间", "")
	if str(冷却) != "":
		最终描述 += "冷却时间" + ("%.1f" % 冷却) + "\n"
	# 4. 构造主体：解析特殊注释中的动态标签
	var 原始注释 = 技能数据.get("特殊注释", "")
	if 原始注释 != "":
		var 处理后的注释 = 解析自定义文本(原始注释)
		最终描述 += 处理后的注释
	return 最终描述

func 接口_道具获得前(道具编号 : int) -> bool:
	match 道具编号:
		24:
			var 随机数 = randf()
			if 随机数 <= 全局数据库.道具静态特殊变量数据库["道具24_韭菜盒子坍缩概率值"]:
				物品获得处理(25, 1, 1)
				var 生成通知框 = 全局数据库.UI资源预加载数据库["UI_通知框"].instantiate()
				var 通知文本 = "你只收到了一个韭菜盒子\n很可惜\n缺的营养这一块没人给你补上"
				生成通知框.显示文本 = 通知文本
				生成通知框.显示时间 = 2
				全局数据_系统.当前场景UI层实例.add_child(生成通知框)
				播放音频("基础音效_按键声3")
				return false
		99:
			var 适用概率值 : float
			if 全局数据_周期对局.当前角色编号 == 8:
				适用概率值 = 全局数据库.道具静态特殊变量数据库["道具99_芙莉莲触发概率值"]
			else:
				适用概率值 = 全局数据库.道具静态特殊变量数据库["道具99_触发概率值"]
			var 随机数 = randf()
			if 随机数 <= 适用概率值:
				物品获得处理(104, 1, 1)
				return false
			else:
				物品获得处理(103, 1, 1)
				return false
	return true

func 接口_技能获得前(_技能编号 : int) -> bool:
	return true

func 接口_道具获得时(道具编号 : int) -> bool:
	match 道具编号:
		40:
			修改玩家属性值("金钱数", 2, 全局数据库.道具静态特殊变量数据库["道具40_获得金钱数"])
		71:
			修改玩家属性值("玩家属性_等级", 3, 全局数据库.道具静态特殊变量数据库["道具71_等级回退数值"])
		83:
			修改玩家属性值("额外属性_商店免费刷新次数", 2, 全局数据库.道具静态特殊变量数据库["道具83_获得商店免费刷新次数"])
		92, 93, 94, 95, 96, 97, 98:
			var 当前角色名称 = 全局数据库.角色数据库[全局数据_周期对局.当前角色编号]["角色名称"]
			var 拼接技能数据库键名 = "技能数据库_" + 当前角色名称
			var 遍历获得技能等级 : int = 1
			var 复制当前角色技能数据库_技能等级次级索引 = 全局数据库.技能数据库_技能等级次级索引[拼接技能数据库键名].duplicate()
			while 遍历获得技能等级 <= 全局数据_环境.道具最大等级:
				var 遍历该等级获得技能数量 =  全局数据库.道具静态特殊变量数据库.get("道具" + str(道具编号) + "_卡片数量_等级" + str(遍历获得技能等级), 0)
				while 遍历该等级获得技能数量 > 0:
					if 复制当前角色技能数据库_技能等级次级索引[遍历获得技能等级].size() == 0:
						break
					var 随机技能编号 = 复制当前角色技能数据库_技能等级次级索引[遍历获得技能等级].pick_random()
					if 全局数据_周期对局.技能持有数据.has(随机技能编号) and 全局数据_周期对局.技能持有数据[随机技能编号] == -999:
						复制当前角色技能数据库_技能等级次级索引[遍历获得技能等级].erase(随机技能编号)
						continue
					物品获得处理(随机技能编号, 2, 1)
					遍历该等级获得技能数量 -= 1
				遍历获得技能等级 += 1
		101:
			修改玩家属性值("额外属性_经验值修改增幅", 3, 全局数据库.道具静态特殊变量数据库["道具101_失去经验获取数值"])
		102:
			修改玩家属性值("额外属性_经验值修改增幅", 2, 全局数据库.道具静态特殊变量数据库["道具102_获得经验获取数值"])
		103:
			var 随机金币 = randi_range(全局数据库.道具静态特殊变量数据库["道具99_获得金币最小值"], 全局数据库.道具静态特殊变量数据库["道具99_获得金币最大值"],)
			修改玩家属性值("金钱数", 2, 随机金币)
			var 生成通知框 = 全局数据库.UI资源预加载数据库["UI_通知框"].instantiate()
			var 通知文本 = "宝箱内一共有" + str(随机金币) + "金币"
			生成通知框.显示文本 = 通知文本
			生成通知框.显示时间 = 2
			全局数据_系统.当前场景UI层实例.add_child(生成通知框)
			播放音频("基础音效_按键声3")
		104:
			if not 全局数据_周期对局.道具动态特殊变量字典_跨波次.has("道具104_生效数量"):
				全局数据_周期对局.道具动态特殊变量字典_跨波次["道具104_生效数量"] = 0
			全局数据_周期对局.道具动态特殊变量字典_跨波次["道具104_生效数量"] += 1
			var 生成通知框 = 全局数据库.UI资源预加载数据库["UI_通知框"].instantiate()
			var 通知文本 = "你遭遇了宝箱怪！！！"
			生成通知框.显示文本 = 通知文本
			生成通知框.显示时间 = 2
			全局数据_系统.当前场景UI层实例.add_child(生成通知框)
			播放音频("基础音效_按键声3")
		105:
			修改玩家属性值("额外属性_经验值修改增幅", 2, 全局数据库.道具静态特殊变量数据库["道具105_获得经验获取数值"])
	return true

func 接口_技能获得时(_技能编号 : int) -> bool:
	return true

func 生成分辨率列表() -> void:
	可选分辨率列表.clear()
	# 1. 获取当前显示器的实际分辨率
	# 使用屏幕索引 0（主屏幕），或者获取当前窗口所在的屏幕
	var 屏幕索引 = DisplayServer.window_get_current_screen()
	var 屏幕尺寸 = DisplayServer.screen_get_size(屏幕索引)
	print("已自动获取屏幕尺寸：", 屏幕尺寸)
	# 2. 计算最大支持的倍数
	var 最大倍数_宽 = 屏幕尺寸.x / 基础宽度
	var 最大倍数_高 = 屏幕尺寸.y / 基础高度
	var 最大倍数 = min(最大倍数_宽, 最大倍数_高)
	# 3. 循环生成整数倍分辨率
	for i in range(1, 最大倍数 + 1):
		var 宽度 = 基础宽度 * i
		var 高度 = 基础高度 * i
		if 宽度 < 屏幕尺寸.x and 高度 < 屏幕尺寸.y:
			可选分辨率列表.append(Vector2i(宽度, 高度))
	# 4. 打印一下结果，方便调试
	print("已自动生成可选分辨率：", 可选分辨率列表)

func 显示模式切换() -> void:
	# 逻辑：在所有窗口化选项中循环，最后接一个全屏模式
	# 索引范围：0 到 可选分辨率列表.size() (多出的一个位置给全屏)
	当前显示模式索引 = (当前显示模式索引 + 1) % (可选分辨率列表.size() + 1)
	
	if 当前显示模式索引 < 可选分辨率列表.size():
		var 目标尺寸 = 可选分辨率列表[当前显示模式索引]
		应用窗口化(目标尺寸)
	else:
		应用全屏()

func 应用窗口化(尺寸 : Vector2i) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_size(尺寸)
	
	# 居中显示
	var 屏幕尺寸 = DisplayServer.screen_get_size()
	@warning_ignore("integer_division")
	var 居中位置 = (屏幕尺寸 - 尺寸) / 2
	DisplayServer.window_set_position(居中位置)
	print("切换至窗口模式: ", 尺寸)

func 应用全屏() -> void:
	# 无边框窗口全屏（会自动匹配当前屏幕分辨率）
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	print("切换至全屏模式")

func 切换鼠标状态(是否显示 : bool) -> void:
	鼠标当前可见 = 是否显示
	if 是否显示:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# print("检测到鼠标输入：显示光标")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		# print("检测到手柄或键盘输入：隐藏光标")

func 执行获取播放器() -> AudioStreamPlayer:
	var 播放器实例 : AudioStreamPlayer
	if 空闲播放器组.size() > 0:
		播放器实例 = 空闲播放器组.pop_back()
	else:
		播放器实例 = AudioStreamPlayer.new()
		add_child(播放器实例)
	return 播放器实例

func 执行收回播放器(目标播放器 : AudioStreamPlayer) ->void:
	if 目标播放器.is_playing():
		目标播放器.stop()
	if not 目标播放器 in 空闲播放器组:
		空闲播放器组.append(目标播放器)

func 音频资源设置循环(资源 : AudioStream, 是否循环 : bool) ->void:
	if 资源 is AudioStreamWAV:
		资源.loop_mode = AudioStreamWAV.LOOP_FORWARD if 是否循环 else AudioStreamWAV.LOOP_DISABLED
	elif 资源 is AudioStreamOggVorbis:
		资源.loop = 是否循环

func 重置全部变量(目标对象, 存储字典: Dictionary) -> void:
	if 存储字典.is_empty(): 
		print(目标对象.name % "：错误：尚未记录初始状态！")
		return
	for 名字 in 存储字典:
		var 值 = 存储字典[名字]
		if 值 is Array or 值 is Dictionary:
			目标对象.set(名字, 值.duplicate(true))
		elif 值 is PackedInt32Array or 值 is PackedFloat32Array:
			目标对象.set(名字, 值.duplicate())
		else:
			目标对象.set(名字, 值)

func 重置单个变量(目标对象, 存储字典: Dictionary, 变量名: String) -> void:
	if not 存储字典.has(变量名):
		print(目标对象.name % "：错误：变量不存在: " % 变量名)
		return
	var 初始值 = 存储字典[变量名]
	if 初始值 is Array or 初始值 is Dictionary:
		目标对象.set(变量名, 初始值.duplicate(true))
	elif 初始值 is PackedInt32Array or 初始值 is PackedFloat32Array:
		目标对象.set(变量名, 初始值.duplicate())
	else:
		目标对象.set(变量名, 初始值)

func 解析获取路径文本对应值(路径: String):
# --- 0. 核心修复：多参数函数解析器 ---
	if "(" in 路径 and ")" in 路径:
		# 正则表达式解释：
		# ([^\\(]+) -> 匹配左括号前的函数完整路径 (例如: 全局方法.生成伤害数值文本)
		# \\("(.+)"\\) -> 匹配括号内被双引号包裹的所有内容
		var regex = RegEx.new()
		regex.compile("([^\\(]+)\\(\"(.+)\"\\)")
		var result = regex.search(路径)
		
		if result:
			var 完整函数路径 = result.get_string(1).strip_edges()
			var 原始参数字符串 = result.get_string(2) # 得到: 角色_长崎素世", "2_啊岚刀一直切
			
			# 提取纯函数名
			var 函数名 = 完整函数路径.split(".")[-1]
			
			# 处理多个参数：通过 "\", \"" 进行分割（这是最稳健的分割点）
			var 参数列表 = 原始参数字符串.split("\", \"")
			
			# --- 针对性分发执行 ---
			if 函数名 == "生成伤害数值文本":
				if 参数列表.size() >= 2:
					# 成功解析出两个参数
					return 生成伤害数值文本(参数列表[0], 参数列表[1])
				elif 参数列表.size() == 1:
					# 兼容旧版本单参数调用
					return 生成伤害数值文本(参数列表[0])
			if 函数名 == "生成卡片技能持有数据":
				return 生成卡片技能持有数据(参数列表[0])
			
			return "函数执行失败或参数不足:" + 函数名
		return "正则解析失败:" + 路径
	# --- 1. 预处理：常规路径解析（以下是你原来的逻辑） ---
	var 段落 = 路径.split(".")
	if 段落.size() == 0:
		return "解析获取路径文本对应值出现空路径"
	var 当前对象 = null
	# --- 2. 初始对象映射 ---
	var 初始段 = 段落[0]
	var 初始名 = 初始段
	if "[" in 初始段:
		初始名 = 初始段.split("[")[0]
	match 初始名:
		"全局方法": 当前对象 = 全局方法
		"全局数据库": 当前对象 = 全局数据库
		"全局数据_环境": 当前对象 = 全局数据_环境
		"全局数据_系统": 当前对象 = 全局数据_系统
		"全局数据_周期对局": 当前对象 = 全局数据_周期对局
		"全局数据_周期波次": 当前对象 = 全局数据_周期波次
		"全局数据_游玩进度": 当前对象 = 全局数据_游玩进度
		
	if 当前对象 == null: 
		return "未知起点:" + 初始名
	# --- 3. 逐段解析 ---
	for i in range(段落.size()):
		var 这一段 = 段落[i]
		var 元素列表 = 这一段.split("[") 
		for j in range(元素列表.size()):
			var 元素 = 元素列表[j].replace("]", "")
			if 元素 == "" or (i == 0 and j == 0): 
				continue
			if "\"" in 元素:
				var 键名 = 元素.replace("\"", "")
				当前对象 = 当前对象.get(键名)
			elif 元素.is_valid_int():
				var 索引 = 元素.to_int()
				if 当前对象 is Array:
					if 索引 < 当前对象.size():
						当前对象 = 当前对象[索引]
					else: return "数组越界"
				elif 当前对象 is Dictionary:
					if 当前对象.has(索引):
						当前对象 = 当前对象[索引]
					elif 当前对象.has(str(索引)):
						当前对象 = 当前对象[str(索引)]
					else: return "字典无此数字键"
			else:
				当前对象 = 当前对象.get(元素)
			if 当前对象 == null:
				return "路径断裂:" + 元素
	return 当前对象

func 生成伤害数值文本(对象名: String, 状态名: String = "") -> String:
	var 拼接状态数据库键名 = "状态数据库_" + 对象名
	var 查找状态数据库 = 全局数据库.状态数据库[拼接状态数据库键名]
	var 技能数据 = 查找状态数据库.get(状态名, {})
	if 技能数据.is_empty():
		return "生成伤害数值文本：技能状态不存在"
	var 基础 = 技能数据.get("当前技能基础伤害", 0)
	var 物理 = 技能数据.get("当前技能物理伤害", 0)
	var 魔法 = 技能数据.get("当前技能魔法伤害", 0)
	var 结果数组 = []
	if int(基础) > 0:
		结果数组.append(str(基础) + "FD")
	if int(物理) > 0:
		结果数组.append(str(物理) + "AD")
	if int(魔法) > 0:
		结果数组.append(str(魔法) + "AP")
	if 结果数组.is_empty():
		return "无伤害"
	# 严谨拼接：a + b + c
	var 文本 = ""
	for i in range(结果数组.size()):
		if i > 0: 文本 += "+"
		文本 += 结果数组[i]
	return 文本

func 生成卡片技能持有数据(技能编号: String) -> String:
	var 获取数据 = 全局数据_周期对局.卡片技能持有数据.get(int(技能编号), 0)
	var 生成字符串 = "(持有数量" + str(获取数据) + ")"
	return 生成字符串
