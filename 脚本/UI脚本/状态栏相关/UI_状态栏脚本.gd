extends Control

var 额外UI连接点集合 : Node

func _ready() -> void:
	额外UI连接点集合 = self.get_node("额外UI连接点集合")
	var 当前角色技能背包类型 = 全局数据库.角色数据库[全局数据_周期对局.当前角色编号]["角色技能背包类型"]
	
	#左侧相关
	var 左侧额外UI名称列表 : Array = []
	if 当前角色技能背包类型 == 2:
		左侧额外UI名称列表.append("UI_状态栏_额外UI_能量")
	if 全局数据_周期对局.当前角色编号 == 3:
		左侧额外UI名称列表.append("UI_状态栏_额外UI_千本樱")
	if 全局数据_周期对局.当前角色编号 == 5:
		左侧额外UI名称列表.append("UI_状态栏_额外UI_子弹")
	
	var 遍历索引 : int = 0
	while true:
		if 遍历索引 == 左侧额外UI名称列表.size():
			break
		var 拼接连接点名称 = "左侧额外UI连接点" + str(遍历索引 + 1)
		if not 额外UI连接点集合.has_node(拼接连接点名称):
			break
		var 获取连接点坐标 : Vector2 = 额外UI连接点集合.get_node(拼接连接点名称).global_position
		生成额外UI(左侧额外UI名称列表[遍历索引], 获取连接点坐标)
		遍历索引 += 1
	
	#右侧相关
	
	#更多

func 生成额外UI(UI对象名称 : String, 坐标 : Vector2) -> Node:
	var 对象资源 = 全局数据库.UI资源预加载数据库[UI对象名称]
	var 生成UI对象 = 对象资源.instantiate()
	生成UI对象.global_position = 坐标
	self.add_child(生成UI对象)
	return 生成UI对象
