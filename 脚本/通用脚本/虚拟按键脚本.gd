extends TouchScreenButton

@export var 触发输入列表 : Array[String] = []

func _ready() -> void:
	self.action = "" 
	self.pressed.connect(按下虚拟按键)
	self.released.connect(松开虚拟按键)

func 按下虚拟按键() -> void:
	for 动作名 in 触发输入列表:
		if InputMap.has_action(动作名):
			var 虚拟输入事件 = InputEventAction.new()
			虚拟输入事件.action = 动作名
			虚拟输入事件.pressed = true
			Input.parse_input_event(虚拟输入事件)

func 松开虚拟按键() -> void:
	for 动作名 in 触发输入列表:
		if InputMap.has_action(动作名):
			var 虚拟输入事件 = InputEventAction.new()
			虚拟输入事件.action = 动作名
			虚拟输入事件.pressed = false
			Input.parse_input_event(虚拟输入事件)
