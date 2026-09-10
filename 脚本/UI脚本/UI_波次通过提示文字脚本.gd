extends Control

var 倒计时节点 = null

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	全局数据_系统.是否禁用打开背包界面 = true
	全局数据_系统.是否禁用打开技能界面 = true
	全局数据_系统.是否禁用打开菜单界面 = true
	倒计时节点 = self.get_node("倒计时节点")
	倒计时节点.connect("timeout", 提示文字结束)
	倒计时节点.start()

func 提示文字结束() -> void:
	全局数据_系统.是否禁用打开背包界面 = false
	全局数据_系统.是否禁用打开技能界面 = false
	self.queue_free()
	if 全局数据_周期波次.记录升级次数 > 0:
		var 生成奖励界面 = 全局数据库.UI资源预加载数据库["UI_商店界面"].instantiate()
		生成奖励界面.界面模式扩展 = 2
		全局数据_系统.当前场景UI层实例.add_child(生成奖励界面)
	else:
		get_tree().paused = false
		全局方法.切换场景("商店界面场景")
