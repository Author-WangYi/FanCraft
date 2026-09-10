extends RichTextLabel

@export var 文本受设备类型控制 : bool = false
@export var 设备类型文本1 : String = ""
@export var 设备类型文本2 : String = ""

@export var 滚动条宽度 : int = 8
@export var 滑块颜色 : Color = Color("#ffffff")
@export var 滑块边框颜色 : Color = Color("#000000")
@export var 滑块边框宽度 : int = 0
@export var 滑块垂直最小长度 : int = 10  # 对应 content_margin_top/bottom
@export var 轨道颜色 : Color = Color("#333333")
@export var 轨道左右边距 : int = 2      # 决定轨道内部的留白

var 滚动速度 = 0.5
var 滚动方向 = 1

func _ready() -> void:
	get_v_scroll_bar().step = 0
	设置滚动条样式()
	if 文本受设备类型控制:
		全局方法.输入设备更换.connect(文本因设备改变)
		文本因设备改变()

func _input(事件) -> void:
	# 仅在按下“翻阅”键的那一瞬间触发
	if 事件.is_action_pressed("翻阅"):
		var 垂直滚动条 = get_v_scroll_bar()
		var 最大滚动范围 = 垂直滚动条.max_value - 垂直滚动条.page
		if 最大滚动范围 <= 0:
			return
		# 停止当前正在运行的动画，防止多次点击导致动画冲突
		var 动画 = create_tween()
		# 设置过渡曲线，TRANS_SINE 比较平滑，EASE_OUT 让结尾有减速感
		动画.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		# 1. 触底判断：如果已经接近底部，则回滚到顶
		if 垂直滚动条.value >= 最大滚动范围:
			# 0.4 秒回到顶端
			动画.tween_property(垂直滚动条, "value", 0.0, 0.4)
		# 2. 正常翻页：向下跳转半个页面
		else:
			var 目标值 = min(垂直滚动条.value + (垂直滚动条.page * 0.5), 最大滚动范围)
			# 0.25 秒滑到下一段
			动画.tween_property(垂直滚动条, "value", 目标值, 0.25)

func 设置滚动条样式() -> void:
	self.add_theme_constant_override("scroll_bar_width", 滚动条宽度)
	var 实际滚动条 = self.get_v_scroll_bar()
	
	var 滑块样式 = StyleBoxFlat.new()
	滑块样式.bg_color = 滑块颜色
	滑块样式.set_border_width_all(滑块边框宽度)
	滑块样式.border_color = 滑块边框颜色
	滑块样式.anti_aliasing = false
	滑块样式.content_margin_top = 滑块垂直最小长度
	滑块样式.content_margin_bottom = 滑块垂直最小长度
	var 轨道样式 = StyleBoxFlat.new()
	轨道样式.bg_color = 轨道颜色
	轨道样式.anti_aliasing = false
	轨道样式.content_margin_left = 轨道左右边距
	轨道样式.content_margin_right = 轨道左右边距
	
	实际滚动条.add_theme_stylebox_override("grabber", 滑块样式)
	实际滚动条.add_theme_stylebox_override("grabber_highlight", 滑块样式)
	实际滚动条.add_theme_stylebox_override("grabber_pressed", 滑块样式)
	实际滚动条.add_theme_stylebox_override("scroll", 轨道样式)

func 文本因设备改变() -> void:
	match 全局方法.当前输入设备:
		1:
			self.text = 全局数据库.通用文本数据库[设备类型文本1]
		2:
			self.text = 全局数据库.通用文本数据库[设备类型文本2]
