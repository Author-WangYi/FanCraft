extends Node2D

var 总节点 : Node = null

var 放大节点_3倍 : Node = null
var 等级展示框 : Sprite2D = null
var 物品图标 : Sprite2D = null
var 选中图片 : Sprite2D = null

var 名称显示 : RichTextLabel = null
var 描述显示 : RichTextLabel = null
var 数量显示 : RichTextLabel = null
var 价格显示 : RichTextLabel = null
var gui输入区域 : Control = null

@export var 格子序号 : int = 1

func _ready() -> void:
	总节点 = self.owner
	总节点.通知_商品显示渲染.connect(渲染更新)
	
	放大节点_3倍 = self.get_node("放大节点_3倍")
	等级展示框 = 放大节点_3倍.get_node("等级展示框")
	物品图标 = 放大节点_3倍.get_node("物品图标")
	选中图片 = 放大节点_3倍.get_node("选中图片")
	
	名称显示 = self.get_node("名称显示")
	描述显示 = self.get_node("描述显示")
	价格显示 = self.get_node("价格显示")
	
	数量显示 = 放大节点_3倍.get_node("数量显示")
	gui输入区域 = 放大节点_3倍.get_node("gui输入区域")
	gui输入区域.mouse_entered.connect(鼠标进入处理)
	gui输入区域.gui_input.connect(gui输入处理)

func 渲染更新() -> void:
	var 当前查看物品类型 = 总节点.商品类型字典.get(格子序号, 0)
	match 当前查看物品类型:
		0:
			等级展示框.texture = null
			物品图标.texture = null
			名称显示.text = ""
			描述显示.text = ""
			数量显示.text = ""
			价格显示.text = ""
		1:
			var 当前查看物品编号 = 总节点.商品编号字典.get(格子序号, 0)
			var 当前查看物品数量 = 总节点.商品数量字典.get(格子序号, 0)
			var 当前查看物品价格 = 总节点.商品价格字典.get(格子序号, 0)
			
			var 物品数据 = 总节点.道具数据库[当前查看物品编号]
			var 物品等级 = 物品数据["道具等级"]
			var 拼接等级框键名 = "商店_展示框_等级%d" % 物品等级
			等级展示框.texture = 全局数据库.图片资源预加载数据库[拼接等级框键名]
			var 拼接图标键名 = "道具图标%d" % 当前查看物品编号
			物品图标.texture = 全局数据库.图片资源预加载数据库[拼接图标键名]
			名称显示.text = 全局方法.解析自定义文本(物品数据["道具名称"])
			描述显示.text = 全局方法.生成道具描述文本(当前查看物品编号)
			if 当前查看物品数量 > 1:
				数量显示.text = str(当前查看物品数量)
			else:
				数量显示.text = ""
			价格显示.text = str(当前查看物品价格)
		2:
			var 当前查看物品编号 = 总节点.商品编号字典.get(格子序号, 0)
			var 当前查看物品数量 = 总节点.商品数量字典.get(格子序号, 0)
			var 当前查看物品价格 = 总节点.商品价格字典.get(格子序号, 0)
			
			var 物品数据 = 总节点.当前角色技能数据库[当前查看物品编号]
			var 物品等级 = 物品数据["技能等级"]
			var 拼接等级框键名 = "商店_展示框_等级%d" % 物品等级
			等级展示框.texture = 全局数据库.图片资源预加载数据库[拼接等级框键名]
			var 拼接图标键名 = 总节点.当前角色名称 + ("_技能图标%d" % 当前查看物品编号)
			物品图标.texture = 全局数据库.图片资源预加载数据库[拼接图标键名]
			名称显示.text = 全局方法.解析自定义文本(物品数据["技能名称"])
			描述显示.text = 全局方法.生成技能描述文本(当前查看物品编号)
			if 当前查看物品数量 == -999:
				数量显示.text = ""
			else:
				数量显示.text = str(当前查看物品数量)
			价格显示.text = str(当前查看物品价格)
	if 总节点.选择模式 == 1 and 总节点.选择栏位数 == 格子序号:
		选中图片.visible = true
	else:
		选中图片.visible = false

func 鼠标进入处理() -> void:
	总节点.选择栏位数 = 格子序号
	总节点.切换查看商品栏位()

func gui输入处理(输入事件 : InputEvent) -> void:
	if not 输入事件.is_pressed():
		return
	if 输入事件 is InputEventMouseButton:
		if 输入事件.button_index == MOUSE_BUTTON_LEFT:
			总节点.选择栏位数 = 格子序号
			总节点.确认查看商品栏位()
