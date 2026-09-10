extends Node

var 调试功能_代码 : String
var 调试功能_运行代码 : bool = false:
	set(新值):
		if 新值 == true:
			调试功能_运行动态代码()
		调试功能_运行代码 = false

var 预制调试_增加1000金钱 : bool = false:
	set(新值):
		if 新值 == true:
			全局数据_周期对局.金钱数 += 1000
		预制调试_增加1000金钱 = false

var 预制调试_增加30经验值 : bool = false:
	set(新值):
		if 新值 == true:
			全局数据_周期对局.经验值 += 30
		预制调试_增加30经验值 = false

var 预制调试_获得全部技能 : bool = false:
	set(新值):
		if 新值 == true:
			var 当前角色名称 = 全局数据库.角色数据库[全局数据_周期对局.当前角色编号]["角色名称"]
			var 拼接技能数据库字符串 = "技能数据库_" + 当前角色名称
			var 当前角色技能数据库 = 全局数据库.技能数据库[拼接技能数据库字符串]
			for 遍历键 in 当前角色技能数据库:
				全局方法.物品获得处理(遍历键, 2)
		预制调试_获得全部技能 = false

var 预制调试_增加100波次时间 : bool = false:
	set(新值):
		if 新值 == true:
			全局数据_系统.当前场景地图基础模块实例.当前波次倒计时 += 100
		预制调试_增加100波次时间 = false

var 预制调试_波次时间变为1 : bool = false:
	set(新值):
		if 新值 == true:
			全局数据_系统.当前场景地图基础模块实例.当前波次倒计时 = 1
		预制调试_增加100波次时间 = false

func _ready() -> void:  #在这里写测试需要的代码
	self.process_mode = Node.PROCESS_MODE_ALWAYS

func 调试功能_运行动态代码() -> void:
	if 调试功能_代码.strip_edges() == "":
		print("【调试功能】代码是空的")
		return
	print("【调试功能】执行动态代码：", 调试功能_代码)
	var 临时脚本 = GDScript.new()
	# 严谨封装：将输入的代码包装在一个函数内
	# 注意：为了能访问当前节点的变量，我们需要继承自当前节点的类型
	var 包装代码 = "extends Node\n\nfunc 运行(目标):\n"
	# 为输入代码增加缩进
	for 一行 in 调试功能_代码.split("\n"):
		包装代码 += "\t" + 一行 + "\n"
	临时脚本.source_code = 包装代码
	var 错误 = 临时脚本.reload()
	if 错误 != OK:
		print("【调试功能】语法错误，无法编译")
		return
	# 创建实例并运行
	var 脚本实例 = Node.new()
	脚本实例.set_script(临时脚本)
	# 将当前对象(self)传进去，这样你在输入的代码里可以用“目标”来操作这个节点
	脚本实例.运行(self)
