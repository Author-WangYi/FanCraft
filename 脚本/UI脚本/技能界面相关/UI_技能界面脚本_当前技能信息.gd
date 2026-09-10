extends Node2D

var 总节点 : Node = null

var 放大节点_3倍 : Node = null
var 等级展示框 : Sprite2D = null
var 技能图标 : Sprite2D = null

var 当前技能名称显示 : RichTextLabel = null
var 当前技能描述显示 : RichTextLabel = null

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_技能显示渲染.connect(渲染更新)
	
	放大节点_3倍 = self.get_node("放大节点_3倍")
	等级展示框 = 放大节点_3倍.get_node("等级展示框")
	技能图标 = 放大节点_3倍.get_node("技能图标")
	
	当前技能名称显示 = self.get_node("当前技能名称显示")
	当前技能描述显示 = self.get_node("当前技能描述显示")

func 渲染更新() -> void:
	var 当前查看技能编号 = 0
	match 总节点.选择模式:
		1:
			当前查看技能编号 = 全局数据_周期对局.技能编号_键位[全局数据_系统.当前查看技能键位组合]
		2:
			if 总节点.当前键位背包技能数量 > 0:
				当前查看技能编号 = 总节点.当前键位背包技能编号列表[全局数据_系统.当前查看技能栏位数]
		3:
			等级展示框.texture = null
			技能图标.texture = null
			当前技能名称显示.text = ""
			当前技能描述显示.text = ""
	if 当前查看技能编号 == 0:
		等级展示框.texture = null
		技能图标.texture = null
		当前技能名称显示.text = ""
		当前技能描述显示.text = ""
	else:
		var 技能等级 = 总节点.当前角色技能数据库[当前查看技能编号]["技能等级"]
		var 拼接等级框键名 = "背包_展示框_等级%d" % 技能等级
		等级展示框.texture = 全局数据库.图片资源预加载数据库[拼接等级框键名]
		var 拼接图标键名 = 总节点.当前角色名称 + ("_技能图标%d" % 当前查看技能编号)
		技能图标.texture = 全局数据库.图片资源预加载数据库[拼接图标键名]
		var 当前技能数据 = 总节点.当前角色技能数据库[当前查看技能编号]
		当前技能名称显示.text = 全局方法.解析自定义文本(当前技能数据["技能名称"])
		当前技能描述显示.text = 全局方法.生成技能描述文本(当前查看技能编号)
