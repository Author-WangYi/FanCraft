extends RichTextLabel

var 记录值 = 0

func _physics_process(_步进时间 : float) -> void:
	var 获取值 = 全局数据_周期对局.金钱数
	if 获取值 != 记录值:
		self.text = str(int(获取值))
		记录值 = 获取值
