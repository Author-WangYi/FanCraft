extends Camera2D

var 跟随目标 = null
var 抖动强度 : float = 0.0
var 抖动倒计时 : float = 5.0
var 衰减速度 : float = 0.0

func _ready() -> void:
	全局方法.当前摄像机实例 = self

func _physics_process(步进时间 : float) -> void :
	if not is_instance_valid(跟随目标):
		var 镜头列表 = get_tree().get_nodes_in_group("摄像机镜头")
		if 镜头列表.size() > 0 :
			跟随目标 = 镜头列表[0]
	if is_instance_valid(跟随目标):
		self.global_position = 跟随目标.global_position
	
	if 抖动倒计时 > 0:
		# 每一帧根据强度随机产生一个偏移
		var 随机偏移 = Vector2(randf_range(-抖动强度, 抖动强度), randf_range(-抖动强度, 抖动强度))
		# 既然分辨率是 640x360，建议将偏移量取整，防止像素撕裂
		self.offset = 随机偏移.round()
		抖动强度 = move_toward(抖动强度, 0, 衰减速度 * 步进时间)
		抖动倒计时 -= 步进时间
	else:
		self.offset = Vector2.ZERO
