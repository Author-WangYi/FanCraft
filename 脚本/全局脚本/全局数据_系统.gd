extends Node
#生命周期为程序启动周期，固定在进入标题界面时重置

var 数据初始镜像 : Dictionary = {}

var UI输入许可 : bool = true
var 角色输入许可 : bool = true

var 当前游玩角色实例 : Node = null
var 当前游玩角色状态机模块实例 : Node = null

var 当前场景地图基础模块实例 : Node = null
var 当前场景实体层实例 : Node = null
var 当前场景UI层实例 : Node = null

var 当前查看背包栏位数 : int = 1  #记录上次背包看的道具，防止退出背包后重新进入变回查看第一个道具

var 当前查看技能键位组合 : int = 1
var 当前查看技能栏位数 : int = 1   #指的是当前查看键位背包技能编号列表的索引

#这两个放在这里是防止玩家选错角色返回后又得回到1号位重新翻
var 当前查看角色类型筛选 : int = 0  #0-全部，1-同人，2-onknow
var 当前查看角色栏位数 : int = 1   #指的是当前筛选模式角色编号列表的索引

var 是否禁用打开背包界面 : bool = true
var 是否禁用打开技能界面 : bool = true
var 是否禁用打开菜单界面 : bool = true
var 背包界面已打开 : bool = false  #技能界面时也算作true
var 菜单界面已打开 : bool = false
var 奖励界面已打开 : bool = false
var 存在通知未结束数量 : int = 0

var 重力加速度 : float = 350

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	全局方法.记录数据初始镜像(self, 数据初始镜像)
