extends Node2D

func _ready() -> void:
	var 分类节点1 = self.get_node("分类节点1")
	var 分类节点2 = self.get_node("分类节点2")
	var 分类节点3 = self.get_node("分类节点3")
	
	var 当前角色技能背包类型 = 全局数据库.角色数据库[全局数据_周期对局.当前角色编号]["角色技能背包类型"]
	if 当前角色技能背包类型 == 1:
		分类节点2.queue_free()
		分类节点3.queue_free()
		分类节点1.visible = true
	elif 当前角色技能背包类型 == 2:
		分类节点1.queue_free()
		分类节点3.queue_free()
		分类节点2.visible = true
	elif 当前角色技能背包类型 == 3:
		分类节点1.queue_free()
		分类节点2.queue_free()
		分类节点3.visible = true
