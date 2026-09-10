extends Node
#数据库需要存储大量数据，所以允许复杂存储，除了数据库以外的变量数据最高只能是一维字典或数组
#数据库都是静态的，用于基础设置，不参与任何动态变化

#普通对象数据库
var 角色数据库 : Dictionary = {}
var 敌人数据库 : Dictionary = {}
var 投射物数据库 : Dictionary = {}
var 敌人投射物数据库 : Dictionary = {}

#这些数据库是多个数据库的整合，key为完整的数据库的名称
var 状态数据库 : Dictionary = {}
var 技能数据库 : Dictionary = {}
var 技能界面光标移动逻辑数据库 : Dictionary = {}

#这些是存放数据的独立数据库
var 波次数据库 : Dictionary = {}
var 道具数据库 : Dictionary = {}
var 地图数据库 : Dictionary = {}
var 背景音乐数据库 : Dictionary = {}
var 角色解锁进度数据库 : Dictionary = {}
var 角色初始技能数据库 : Dictionary = {}
var 角色初始道具数据库 : Dictionary = {}
var 场景数据库 : Dictionary = {}
var 等级数据库 : Dictionary = {}
var 等级奖励数据库 : Dictionary = {}
#这些是存放数据的独立数据库中一维的数据库
var 道具静态特殊变量数据库 : Dictionary = {}
var 通用文本数据库 : Dictionary = {}
var 版本更新内容数据库 : Dictionary = {}
var 小提示文本数据库 : Dictionary = {}

#资源数据库因为内容较多，所以自动扫描填充，保存的是资源路径，是一维字典
var 音频资源数据库 : Dictionary = {}
var 图片资源数据库 : Dictionary = {}
var 普通对象资源数据库 : Dictionary = {}
var UI资源数据库 : Dictionary = {}
var 场景资源数据库 : Dictionary = {}

#保存的是load后的资源
var 音频资源预加载数据库 : Dictionary = {}  #只预加载音效
var 图片资源预加载数据库 : Dictionary = {}
var 普通对象资源预加载数据库 : Dictionary = {}
var UI资源预加载数据库 : Dictionary = {}
var 场景资源预加载数据库 : Dictionary = {}

#数据库的次级索引，key为属性值的筛选，值为筛选出的key组成的数组
var 角色数据库_筛选类型次级索引 : Dictionary = {}
var 角色数据库_对象资源名称次级索引 : Dictionary = {}
var 敌人数据库_对象资源名称次级索引 : Dictionary = {}
var 道具数据库_道具等级次级索引 : Dictionary = {}
var 道具数据库_作为材料可合成次级索引 : Dictionary = {}
var 道具数据库_道具抽取类型次级索引 : Dictionary = {}
var 道具数据库_解锁角色次级索引 : Dictionary = {}
var 道具数据库_白名单角色次级索引 : Dictionary = {}
var 道具数据库_黑名单角色次级索引 : Dictionary = {}
var 背景音乐数据库_背景音乐系列次级索引 : Dictionary = {}
#整合数据库的次级索引，是多个数据库的次级索引的整合，key为数据库的名称
var 状态数据库_当前状态标签次级索引 : Dictionary = {}
var 技能数据库_技能等级次级索引 : Dictionary = {}
var 技能数据库_技能键位次级索引 : Dictionary = {}

func _ready() -> void:
	print("【程序运行测试】全局数据库.gd，_ready()开始运行，运行时间为：", Time.get_ticks_msec())
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	print("程序开始，测试随机值：", randf())
	道具静态特殊变量数据库 = JSON原样导入("res://数据库/道具静态特殊变量数据库.json")
	通用文本数据库 = JSON原样导入("res://数据库/通用文本数据库.json")
	版本更新内容数据库 = JSON转换导入_键转整形("res://数据库/版本更新内容数据库.json")
	小提示文本数据库 = JSON转换导入_键转整形("res://数据库/小提示文本数据库.json")
	场景数据库 = JSON原样导入("res://数据库/场景数据库.json")
	
	道具数据库 = JSON转换导入_键转整形("res://数据库/道具数据库.json")
	角色数据库 = JSON转换导入_键转整形("res://数据库/角色数据库.json")
	敌人数据库 = JSON转换导入_键转整形("res://数据库/敌人数据库.json")
	角色解锁进度数据库 = JSON转换导入_键转整形("res://数据库/角色解锁进度数据库.json")
	角色初始技能数据库 = JSON转换导入_键转整形("res://数据库/角色初始技能数据库.json")
	角色初始道具数据库 = JSON转换导入_键转整形("res://数据库/角色初始道具数据库.json")
	背景音乐数据库 = JSON转换导入_键转整形("res://数据库/背景音乐数据库.json")
	地图数据库 = JSON转换导入_键转整形("res://数据库/地图数据库.json")
	波次数据库 = JSON转换导入_键转整形("res://数据库/波次数据库.json")
	等级数据库 = JSON转换导入_键转整形("res://数据库/等级数据库.json")
	等级奖励数据库 = JSON转换导入_键转整形("res://数据库/等级奖励数据库.json")
	
	JSON文件夹导入(状态数据库, "res://数据库/", "状态数据库_")
	JSON文件夹导入(技能数据库, "res://数据库/", "技能数据库_")
	JSON文件夹导入(技能界面光标移动逻辑数据库, "res://数据库/", "技能界面光标移动逻辑")
	
	资源文件夹扫描路径导入(图片资源数据库, "res://图片资源/技能图标/", ["png"])
	资源文件夹扫描路径导入(图片资源数据库, "res://图片资源/UI/", ["png"])
	资源文件夹扫描路径导入(图片资源数据库, "res://图片资源/道具图标/", ["png"])
	资源文件夹扫描路径导入(图片资源数据库, "res://图片资源/角色图标/", ["png"])
	资源文件夹扫描路径导入(图片资源数据库, "res://图片资源/角色图标_Steam特供版/", ["png"])
	资源数据库批量预加载(图片资源预加载数据库, 图片资源数据库)
	
	资源文件夹扫描路径导入(音频资源数据库, "res://音效素材/", ["wav", "ogg"])
	资源文件夹扫描路径导入(音频资源数据库, "res://音乐/", ["wav", "ogg"])
	资源数据库批量预加载(音频资源预加载数据库, 音频资源数据库)
	
	资源文件夹扫描路径导入(普通对象资源数据库, "res://对象_普通/对象_敌人/", ["tscn"])
	资源文件夹扫描路径导入(普通对象资源数据库, "res://对象_普通/对象_敌人投射物/", ["tscn"])
	资源文件夹扫描路径导入(普通对象资源数据库, "res://对象_普通/对象_投射物/", ["tscn"])
	资源文件夹扫描路径导入(普通对象资源数据库, "res://对象_普通/对象_掉落物/", ["tscn"])
	资源文件夹扫描路径导入(普通对象资源数据库, "res://对象_普通/对象_特效/", ["tscn"])
	资源文件夹扫描路径导入(普通对象资源数据库, "res://对象_普通/对象_角色/", ["tscn"])
	资源数据库批量预加载(普通对象资源预加载数据库, 普通对象资源数据库)
	
	资源文件夹扫描路径导入(UI资源数据库, "res://对象_UI/", ["tscn"])
	资源数据库批量预加载(UI资源预加载数据库, UI资源数据库)
	
	资源文件夹扫描路径导入(场景资源数据库, "res://对象_场景/", ["tscn"])
	资源数据库批量预加载(场景资源预加载数据库, 场景资源数据库)
	
	构建全部次级索引()
	
	
	print("【程序运行测试】全局数据库.gd，_ready()运行结束，运行时间为：", Time.get_ticks_msec())

func 构建全部次级索引() -> void:
	全局方法.构建次级索引(角色数据库_筛选类型次级索引, "角色筛选类型", 角色数据库)
	全局方法.构建次级索引(角色数据库_对象资源名称次级索引, "对象资源名称", 角色数据库)
	全局方法.构建次级索引(敌人数据库_对象资源名称次级索引, "对象资源名称", 敌人数据库)
	
	全局方法.构建次级索引(道具数据库_道具等级次级索引, "道具等级", 道具数据库)
	全局方法.构建次级索引(道具数据库_作为材料可合成次级索引, "作为材料可合成", 道具数据库)
	全局方法.构建次级索引(道具数据库_道具抽取类型次级索引, "道具抽取类型", 道具数据库)
	全局方法.构建次级索引(道具数据库_解锁角色次级索引, "解锁角色", 道具数据库)
	全局方法.构建次级索引(道具数据库_白名单角色次级索引, "白名单角色", 道具数据库)
	全局方法.构建次级索引(道具数据库_黑名单角色次级索引, "黑名单角色", 道具数据库)
	
	全局方法.构建次级索引(背景音乐数据库_背景音乐系列次级索引, "背景音乐系列", 背景音乐数据库)
	
	for 键名 in 状态数据库:
		状态数据库_当前状态标签次级索引[键名] = {}
		全局方法.构建次级索引(状态数据库_当前状态标签次级索引[键名], "当前状态标签", 状态数据库[键名])
	
	for 键名 in 技能数据库:
		技能数据库_技能等级次级索引[键名] = {}
		全局方法.构建次级索引(技能数据库_技能等级次级索引[键名], "技能等级", 技能数据库[键名])
		技能数据库_技能键位次级索引[键名] = {}
		全局方法.构建次级索引(技能数据库_技能键位次级索引[键名], "技能键位", 技能数据库[键名])
	
func JSON原样导入(路径 : String) -> Dictionary:
	var 内容 = FileAccess.get_file_as_string(路径)
	if 内容 == "":
		return {}
	var 数据 = JSON.parse_string(内容)
	if 数据 == null:
		return {}
	# --- 关键修复：清洗数据类型 ---
	return 递归修复数值类型(数据)

func 递归修复数值类型(输入数据):  #尝试把float转换成int，不成立则不做变化
	if 输入数据 is Dictionary:
		var 修复后的字典 = {}
		for 键 in 输入数据:
			修复后的字典[键] = 递归修复数值类型(输入数据[键])
		return 修复后的字典
	elif 输入数据 is Array:
		var 修复后的数组 = []
		for 项 in 输入数据:
			修复后的数组.append(递归修复数值类型(项))
		return 修复后的数组
	elif 输入数据 is float:
		# 核心逻辑：如果浮点数等于它转成整数后的值，说明它是“伪浮点”
		if is_equal_approx(输入数据, round(输入数据)):
			return int(输入数据)
	return 输入数据

func JSON转换导入_键转整形(路径 : String) -> Dictionary:
	var 原始数据 = JSON原样导入(路径)
	var 新字典 : Dictionary = {}
	for 字符Key in 原始数据:
		# 严谨处理：尝试将 Key 转换为整数
		if 字符Key.is_valid_int():
			var 数值Key = int(字符Key)
			新字典[数值Key] = 原始数据[字符Key]
		else:
			# 如果 Key 不是纯数字（比如叫 "version"），则保留原样或跳过
			新字典[字符Key] = 原始数据[字符Key]
	return 新字典

func JSON文件夹导入(目标字典 : Dictionary, 文件夹路径 : String, 前缀要求 : String = "") -> void:
	var 目录 = DirAccess.open(文件夹路径)
	if not 目录:
		print("警告：无法打开路径 -> ", 文件夹路径)
		return
	目录.list_dir_begin()
	var 文件名 = 目录.get_next()
	while 文件名 != "":
		# 逻辑：必须是文件，必须以 .json 结尾
		if not 目录.current_is_dir() and 文件名.ends_with(".json"):
			var 基础名称 = 文件名.get_basename()
			# 严谨逻辑：如果指定了前缀，则文件名必须以此开头
			# 如果前缀为空，则加载该文件夹下所有 json
			if 前缀要求 == "" or 基础名称.begins_with(前缀要求):
				var 完整路径 = 文件夹路径 + 文件名
				var 文件数据 = JSON转换导入_键转整形(完整路径)
				if not 文件数据.is_empty():
					if 目标字典.has(基础名称):
						print("警告：段落 [", 基础名称, "] 重复，正在覆盖。")
					目标字典[基础名称] = 文件数据
		文件名 = 目录.get_next()
	目录.list_dir_end()

func 资源文件夹扫描路径导入(目标字典 : Dictionary, 文件夹路径 : String, 文件后缀 : Array) -> void:
	if not 文件夹路径.ends_with("/"):
		文件夹路径 += "/"
	var 目录 = DirAccess.open(文件夹路径)
	if not 目录:
		print("警告：无法打开路径 -> ", 文件夹路径)
		return
	目录.list_dir_begin()
	var 文件名 = 目录.get_next()
	while 文件名 != "":
		# --- 核心修复开始 ---
		# 在 Android 导出包中，资源往往带有 .import 后缀
		var 实际名 = 文件名.replace(".import", "")
		# 如果是场景文件，可能还有 .remap，一并处理
		实际名 = 实际名.replace(".remap", "")
		if 目录.current_is_dir():
			if 文件名 != "." and 文件名 != "..":
				资源文件夹扫描路径导入(目标字典, 文件夹路径 + 文件名 + "/", 文件后缀)
		else:
			# 这里判断后缀要用处理过的“实际名”
			var 当前后缀 = 实际名.get_extension().to_lower()
			if 当前后缀 in 文件后缀:
				var 基础名称 = 实际名.get_basename()
				var 完整路径 = 文件夹路径 + 实际名
				目标字典[基础名称] = 完整路径
		文件名 = 目录.get_next()
	目录.list_dir_end()

func 资源数据库批量预加载(目标数据库: Dictionary, 原始数据库: Dictionary):
	for 对象名称 in 原始数据库.keys():
		var 资源路径 = 原始数据库[对象名称]
		# 手机端严谨处理：直接尝试加载
		var 加载的资源 = load(资源路径)
		if 加载的资源 != null:
			目标数据库[对象名称] = 加载的资源
		else:
			# 如果加载失败，再打印错误，方便手机连接电脑调试时查看
			print("【资源预加载失败】名称：" + 对象名称 + " 路径：" + 资源路径)
