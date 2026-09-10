extends Node
#生命周期为一局游戏，对局不结束就一直不会重置，开始新游戏前重置
#（切换选择角色时就需要重置，因为切换角色时就已经在修改变量了）
#需要参与存档，因为游戏会在波次开始时进行保存

var 数据初始镜像 : Dictionary = {}

var 当前波次 : int = 0
var 下一波次 : int = 1
var 当前地图编号 : int = 0
var 当前对局进行中 : int = 0

var 当前角色编号 : int = 0

#持有物相关
var 背包总栏数 : int = 0
var 背包存储数据 : Dictionary  #默认key起点为1，不使用0号位，这些都是一维字典
var 道具持有数据 : Dictionary  #如果有对应键，就说明持有
var 技能背包总栏数 : int = 0
var 技能背包存储数据 : Dictionary
var 技能持有数据 : Dictionary  #即技能耐久度数据
var 技能编号_键位 : PackedInt32Array = [0, 0, 0, 0, 0, 0, 0]  #不用怀疑，这里用数组，性能确实好一点，索引0默认为0，没有实际用处
var 卡片技能持有数据 : Dictionary  #卡片类型角色在波次中，技能耐久度会不断变少，这个字典存储着真正的数量信息，波次结束时会把技能耐久度补充到相同数量

#玩家属性相关变量
var 玩家属性_等级 : float = 1
var 玩家属性_最大生命值 : float = 1:
	set(新值):
		var 当前游玩角色状态机模块实例 = 全局数据_系统.当前游玩角色状态机模块实例
		if is_instance_valid(当前游玩角色状态机模块实例):
			当前游玩角色状态机模块实例.生命值最大 = max(新值, 1)
		玩家属性_最大生命值 = max(新值, 1)
var 玩家属性_攻击力上限 : float = 0
var 玩家属性_物理攻击 : float = 0
var 玩家属性_魔法攻击 : float = 0
var 玩家属性_防御力 : float = 0
var 玩家属性_生命再生 : float = 0
var 玩家属性_生命窃取 : float = 0
var 玩家属性_幸运 : float = 0
var 玩家属性_收获 : float = 0
var 玩家属性_强中断阈值 : float = 0
var 玩家属性_弱中断阈值 : float = 0
var 经验值 : float = 0
var 经验值最大 : float = 1
var 金钱数 : float = 0
var 额外属性_商店物品价格倍率 : float = 1
var 额外属性_商店刷新价格倍率 : float = 1
var 额外属性_商店免费刷新次数 : float = 0
var 额外属性_经验值修改增幅 : float = 0

var 角色被击败 : bool = false  #用全局方法的信号代替
var 道具动态特殊变量字典_跨波次 : Dictionary = {}

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	全局方法.记录数据初始镜像(self, 数据初始镜像)
