extends Node
#生命周期为无限，这些数据都绝对不会变动也不需要考虑重置
#与全局数据库类似

var Steam特供版 : bool = false  #这个是特供版的总开关
var Steam特供版角色列表 : Array = [7]

const 游戏版本号 : int = 12
const 存档路径 : String = "user://Save_Data_Author_WangYi.cfg"

const 防御力平衡系数 : float = 50  #防御力计算公式：所受伤害率 = (1 - 防御力 / (防御力 + 防御力平衡系数)) = (防御力平衡系数 / (防御力 + 防御力平衡系数))

const 幸运每阶段值 : float = 50
const 幸运每阶段升级概率 : float = 0.5

const 生命再生每阶段值 : float = 50
const 生命再生每阶段恢复概率值 : float = 0.5
const 生命再生间隔时间 : float = 1

const 生命窃取每阶段值 : float = 50
const 生命窃取每阶段恢复概率值 : float = 0.5

const 每波次敌人生命值倍率变化 : float = 0.05
const 每波次敌人伤害倍率变化 : float = 0.1

const 道具最大等级 : int = 4
const 角色等级需要通过波次 : Dictionary = { 1: 0, 2: 10, 3: 15, 4: 20, 5: 25}
const 玩家属性名称列表 : Array = [
	"等级", "最大生命值", "攻击力上限", "物理攻击", "魔法攻击", 
	"防御力", "生命再生", "生命窃取", "幸运", "收获"
	]
const 键位名称字典1 = {
	1: "攻击键",
	2: "技能键1",
	3: "技能键2",
	4: "技能键3"
}
const 键位名称字典3 = {
	1: "攻击键",
	2: "方向键→ + 技能键1",
	3: "方向键↓ + 技能键1",
	4: "方向键→ + 技能键2",
	5: "方向键↓ + 技能键2",
	6: "技能键3"
}

func _ready() -> void:
	if OS.has_feature("Steam特供版"):
		Steam特供版 = true
		print("【全局数据_环境】检测为Steam特供版")
	else:
		Steam特供版 = false
