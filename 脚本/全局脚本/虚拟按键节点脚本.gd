extends CanvasLayer

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	self.visible = false

func _input(事件: InputEvent) -> void:
	# 1. 排除掉鼠标移动等无意义的干扰
	if 事件 is InputEventMouseMotion:
		return
	# 2. 判断输入来源
	# 触摸屏：InputEventScreenTouch 或 InputEventScreenDrag
	if 事件 is InputEventScreenTouch or 事件 is InputEventScreenDrag:
		self.visible = true
		print("【系统】检测到移动端触屏，显示虚拟按键")
		结束检测工作()
	# 键盘或手柄：判定为非触屏环境
	elif 事件 is InputEventKey or 事件 is InputEventJoypadButton or 事件 is InputEventJoypadMotion:
		self.visible = false
		print("【系统】检测到物理外设，保持虚拟按键隐藏")
		结束检测工作()
	# 注意：如果你在 PC 上开启了“从触摸模拟鼠标”，
	# 那么普通的鼠标点击可能会被识别为触摸，建议在项目设置里关闭模拟。

func 结束检测工作() -> void:
	# 核心逻辑：一旦完成判断，就让该节点不再接收任何输入回调，节省性能
	set_process_input(false)
	# 如果你还有 _process 或 _physics_process，也可以一并关闭
	set_process(false)
