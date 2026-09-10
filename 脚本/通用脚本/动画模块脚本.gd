extends AnimationPlayer

@export var 特效类型对象 : bool = false
@export var 特效结束后释放 : bool = true
var 主节点 : Node = null
var 状态机模块 : Node = null

func _ready() -> void:
	主节点 = self.owner
	if 特效类型对象 == false:
		状态机模块 = 主节点.get_node("状态机模块")
		self.animation_finished.connect(动画结束调用)
	else:
		self.animation_finished.connect(特效动画结束)
		主节点.visibility_changed.connect(特效重新使用)

func 动画结束调用(_动画名称 : StringName) -> void: 
	状态机模块.当前动画已结束 = true

func 特效动画结束(_动画名称 : StringName) -> void:
	if 特效结束后释放 == true:
		主节点.queue_free()
	else:
		主节点.visible = false

func 特效重新使用() -> void:
	self.play()
