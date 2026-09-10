extends Control

var 上层实例 : Node = null  #某些对象生成通知框后，需要等待通知框结束才能进行行动
var 显示文本 : String = "通知文本未配置"
var 水平对齐 = 1
var 垂直对齐 = 1
var 显示行间距 : int = 12
var 显示时间 : float = 2
var 是否启用按键关闭 : bool = false
var 是否启用鼠标点击关闭 : bool = false

var 通知文本 = null
var 倒计时节点 = null

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.z_index = 4
	全局数据_系统.存在通知未结束数量 += 1
	通知文本 = self.get_node("通知文本")
	通知文本.text = 显示文本
	通知文本.horizontal_alignment = 水平对齐
	通知文本.vertical_alignment = 垂直对齐
	通知文本.add_theme_constant_override("line_separation", 显示行间距)
	
	if 显示时间 > 0:
		倒计时节点 = self.get_node("倒计时节点")
		倒计时节点.connect("timeout", 关闭通知框)
		倒计时节点.start(显示时间)

func _input(输入事件: InputEvent) -> void:
	if 全局数据_系统.UI输入许可:
		if 是否启用按键关闭 and 输入事件.is_action_pressed("操作确认"):
			关闭通知框()
			全局方法.UI输入倒计时启动()

func 关闭通知框() -> void:
	if is_instance_valid(上层实例):
		上层实例.通知框已关闭()
	全局数据_系统.存在通知未结束数量 -= 1
	self.queue_free()
