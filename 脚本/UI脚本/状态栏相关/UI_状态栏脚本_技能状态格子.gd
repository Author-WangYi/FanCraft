extends Node2D

@export var 监视技能键位 : int = 1

var 记录角色名称 : String = ""
var 记录技能编号 : int = -1
var 记录倒计时 : float = -1
var 记录冷却时间 : float = -1
var 记录能量是否足够 : bool
var 记录技能消耗能量 : float = -1

var 等级展示框 : Node = null
var 技能图标 : Node = null
var 黑幕 : Node = null
var 倒计时黑幕 : Node = null

var 倒计时黑幕最大缩放x : float
var 倒计时黑幕最大缩放y : float

func _ready() -> void:
	等级展示框 = self.get_node("等级展示框")
	技能图标 = self.get_node("技能图标")
	黑幕 = self.get_node("黑幕")
	倒计时黑幕 = self.get_node("倒计时黑幕")
	倒计时黑幕最大缩放x = 倒计时黑幕.scale.x
	倒计时黑幕最大缩放y = 倒计时黑幕.scale.y

func _physics_process(_步进时间 : float) -> void:
	var 当前游玩角色状态机模块实例 = 全局数据_系统.当前游玩角色状态机模块实例
	if is_instance_valid(当前游玩角色状态机模块实例):
		var 强制更新 : bool = false
		var 获取角色名称 = 当前游玩角色状态机模块实例.该角色名称
		if 记录角色名称 != 获取角色名称:
			记录角色名称 = 获取角色名称
			强制更新 = true
		
		var 获取角色技能背包类型 = 当前游玩角色状态机模块实例.该角色技能背包类型
		var 获取技能编号 = 全局数据_周期对局.技能编号_键位[监视技能键位]
		if 记录技能编号 != 获取技能编号 or 强制更新:  #技能变了，强制更新渲染
			记录技能编号 = 获取技能编号
			if 记录技能编号 == 0:
				渲染更新_重置显示()
				return
			强制更新 = true
			match 获取角色技能背包类型:
				1:
					记录冷却时间 = float(当前游玩角色状态机模块实例.该角色技能数据库[记录技能编号]["冷却时间"])
				2:
					倒计时黑幕.visible = false
					记录技能消耗能量 = float(当前游玩角色状态机模块实例.该角色技能数据库[记录技能编号]["技能消耗"])
		
		if 记录技能编号 == 0:
			渲染更新_重置显示()
			return
		
		match 获取角色技能背包类型:
			1:
				var 获取倒计时 = 当前游玩角色状态机模块实例.技能倒计时[记录技能编号]
				if 记录倒计时 != 获取倒计时 or 强制更新:
					记录倒计时 = 获取倒计时
					var 计算缩放比例 
					if 记录冷却时间 > 0:
						计算缩放比例 = max(记录倒计时 / 记录冷却时间, 0)
						if 计算缩放比例 > 0:
							黑幕.visible = true
						else:
							黑幕.visible = false
					elif 记录冷却时间 == -999:
						计算缩放比例 = 0
						黑幕.visible = true
					else:
						计算缩放比例 = 0
						黑幕.visible = false
					倒计时黑幕.scale.y = 计算缩放比例 * 倒计时黑幕最大缩放y

			2:
				var 获取能量 = 当前游玩角色状态机模块实例.能量
				var 计算能量是否足够 : bool = (获取能量 >= 记录技能消耗能量)
				if 计算能量是否足够 != 记录能量是否足够 or 强制更新:
					记录能量是否足够 = 计算能量是否足够
					if 计算能量是否足够 == false:
						黑幕.visible = true
					else:
						黑幕.visible = false
		
		if 强制更新:
			渲染更新_技能显示()

func 渲染更新_技能显示() -> void:
	var 技能等级 = 全局数据库.技能数据库["技能数据库_" + 记录角色名称][记录技能编号]["技能等级"]
	var 拼接等级展示框图片名称 = "状态栏_缩略展示框_等级" + str(技能等级)
	var 拼接技能图标图片名称 = 记录角色名称 + "_缩略技能图标" + str(记录技能编号)
	等级展示框.texture = 全局数据库.图片资源预加载数据库[拼接等级展示框图片名称]
	技能图标.texture = 全局数据库.图片资源预加载数据库[拼接技能图标图片名称]

func 渲染更新_重置显示() -> void:
	等级展示框.texture = null
	技能图标.texture = null
	黑幕.visible = false
	倒计时黑幕.scale.y = 0
