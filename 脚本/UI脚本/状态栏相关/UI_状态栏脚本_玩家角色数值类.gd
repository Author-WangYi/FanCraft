extends RichTextLabel

class_name 状态栏脚本_玩家角色数值类

@export var 变量名称 : String
@export var 显示类型 : int = 1
var 记录值 = -233

func _physics_process(_步进时间 : float) -> void:
	if is_instance_valid(全局数据_系统.当前游玩角色状态机模块实例):
		var 获取值 = 全局数据_系统.当前游玩角色状态机模块实例.get(变量名称)
		if 获取值 != null and 获取值 != 记录值:
			match 显示类型:
				1:
					self.text = str(int(获取值))
				2:
					self.text = str(float(获取值))
			记录值 = 获取值
