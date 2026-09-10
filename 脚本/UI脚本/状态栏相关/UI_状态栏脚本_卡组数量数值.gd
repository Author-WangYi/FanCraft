extends RichTextLabel

var 记录值 = -233

func _physics_process(_步进时间 : float) -> void:
	if is_instance_valid(全局数据_系统.当前游玩角色状态机模块实例):
		var 获取值 = 全局数据_系统.当前游玩角色状态机模块实例.技能卡组列表.size()
		if 获取值 != 记录值:
			self.text = str(int(获取值))
			记录值 = 获取值
