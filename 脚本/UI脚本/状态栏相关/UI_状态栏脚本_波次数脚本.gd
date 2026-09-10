extends RichTextLabel

func _ready() -> void:
	var 获取值 = 全局数据_周期对局.当前波次
	self.text = "第" + str(int(获取值)) + "波"
