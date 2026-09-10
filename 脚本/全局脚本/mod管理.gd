extends Node

#mod制作可在原游戏工程中进行，先在"res://mods/"里面新建一个文件夹，比如"res://mods/角色美化_by_gugugagahajimi"，这个就是mod项目文件夹
#尽量通过添加前缀后缀的方式让mod项目名足够特殊，避免重名
#在"res://mods/角色美化_by_gugugagahajimi"里面新建一个名为AutoLoad的文件夹，mod管理.gd会专门扫描名为AutoLoad的文件夹，实例化并运行代码，无论mod想干什么都必须通过这个部分实现
#我预留了一个mod导出的模板，注意资源选项也只选择mods文件夹，然后导出为pck或者zip
#mod可放在mods安装文件夹路径（exe启动器旁的mods文件夹）、mods通用文件夹路径（C:\Users\Administrator\AppData\Roaming\Godot\app_userdata\王异工坊FanCraft\mods），或者从Steam创意工坊下载，自动放在Steam官方目录里

signal 全部mod加载完成

var mods项目文件夹路径 : String = "res://mods/"
var mods安装文件夹路径 : String = OS.get_executable_path().get_base_dir().path_join("mods")
var mods通用文件夹路径 : String = "user://mods"
var 自动加载目录名 : String = "AutoLoad"
var 最大扫描层数 : int = 3

var 创意工坊appid : String = "4074320"
var 是否为steam游戏 : bool = false
var steam库根路径 : String = ""
var 创意工坊路径 : String = ""        # 仅当 Steam 且 workshop 存在时非空

var pck文件字典 : Dictionary = {}        # key: pck文件名，value: pck文件路径  （实际上zip文件也可以作为数据包，和pck等效）
var mod项目字典 : Dictionary = {}       # key: mod名（项目内加载后的文件夹名），value: mod根节点
var mod根节点名称字典 : Dictionary = {}

func _ready() -> void:
	print("mods项目文件夹路径：", ProjectSettings.globalize_path(mods项目文件夹路径))
	
	if not DirAccess.dir_exists_absolute(mods安装文件夹路径):
		DirAccess.make_dir_recursive_absolute(mods安装文件夹路径)	
	print("mods安装文件夹路径：", ProjectSettings.globalize_path(mods安装文件夹路径))
	
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(mods通用文件夹路径)):
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(mods通用文件夹路径))
	print("mods通用文件夹路径：", ProjectSettings.globalize_path(mods通用文件夹路径))

	# 0) 检测 Steam 环境
	检测steam环境()
	
	# 1) 挂载所有 .pck
	挂载所有pck文件()
	# 2) 挂载完成后，扫描 res://mods/ 下有哪些文件夹
	扫描mods项目文件夹()
	# 3) 逐个按文件夹名加载
	for 遍历mod项目名 in mod项目字典:
		加载单个mod(遍历mod项目名)
	
	print("[mod管理] 全部mod加载完成")
	全部mod加载完成.emit()

func 检测steam环境() -> void:
	#如果Godot和成品游戏都是从Steam下载的，并且都在同一个盘符的Steam库中，那么Godot启动游戏工程也会被判定为Steam游戏，会加载下载在本地的创意工坊mod
	print("========== Steam 环境检测 ==========")
	var 可执行路径 := OS.get_executable_path()
	var 游戏目录 := 可执行路径.get_base_dir()       # 应为 <库>/steamapps/common/<游戏目录>
	var 父目录 := 游戏目录.get_base_dir()            # 应为 <库>/steamapps/common
	var 祖父目录 := 父目录.get_base_dir()            # 应为 <库>/steamapps

	print("可执行文件：", 可执行路径)
	print("目录层级：游戏目录「%s」→ 父目录「%s」→ 祖父目录「%s」" % [游戏目录.get_file(), 父目录.get_file(), 祖父目录.get_file()])

	# 判定标准：exe 往上 1 级是 common、往上 2 级是 steamapps，才是 Steam 安装结构
	if 父目录.get_file() != "common" or 祖父目录.get_file() != "steamapps":
		是否为steam游戏 = false
		steam库根路径 = ""
		创意工坊路径 = ""
		print("检测结果：不是 Steam 游戏（exe 不在 steamapps/common 结构下）")
		print("==================================")
		return

	是否为steam游戏 = true
	steam库根路径 = 祖父目录.get_base_dir()          # <库>
	var workshop目录 := 祖父目录.path_join("workshop")
	var content目录 := workshop目录.path_join("content")
	var appid目录 := content目录.path_join(创意工坊appid)

	print("Steam 库根目录：", steam库根路径)
	print("workshop 文件夹存在：", DirAccess.dir_exists_absolute(workshop目录))
	print("workshop/content 文件夹存在：", DirAccess.dir_exists_absolute(content目录))
	print("创意工坊内容目录（appid=%s）存在：%s" % [创意工坊appid, DirAccess.dir_exists_absolute(appid目录)])

	if DirAccess.dir_exists_absolute(workshop目录):
		创意工坊路径 = appid目录
		print("检测结果：是 Steam 游戏，已找到 workshop 文件夹")
		if DirAccess.dir_exists_absolute(appid目录):
			print("         已订阅并下载了 mod，创意工坊路径：", 创意工坊路径)
		else:
			print("         尚无订阅的 mod 内容（appid 目录不存在，属正常现象）")
	else:
		创意工坊路径 = ""
		print("检测结果：是 Steam 游戏，但未找到 workshop 文件夹（可能从未订阅过内容）")

	print("==================================")

func 挂载所有pck文件() -> void:
	# ① exe 旁 mods 目录：递归扫 3 层（导出后玩家的 mod 入口）
	if DirAccess.dir_exists_absolute(mods安装文件夹路径):
		收集pck(mods安装文件夹路径, 最大扫描层数)
	
	# ② 工程内 res://mods/：递归扫 3 层（开发期直投）
	if DirAccess.dir_exists_absolute(mods项目文件夹路径):
		收集pck(mods项目文件夹路径, 最大扫描层数)
	
	# ③ user://mods：递归扫 3 层
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(mods通用文件夹路径)):
		收集pck(mods通用文件夹路径, 最大扫描层数)

	# ④ 创意工坊目录：Steam 订阅下载的 mod
	if 是否为steam游戏 and 创意工坊路径 != "" and DirAccess.dir_exists_absolute(创意工坊路径):
		收集pck(创意工坊路径, 最大扫描层数)
	
	print("pck文件字典：", pck文件字典)
	
	for 遍历pck文件名 in pck文件字典:
		var 遍历pck文件路径 = pck文件字典[遍历pck文件名]
		if not ProjectSettings.load_resource_pack(遍历pck文件路径, false):
			print("[mod管理] pck挂载失败：" + 遍历pck文件路径)

func 收集pck(目录路径: String, 剩余层数: int) -> void:
	if 剩余层数 <= 0:
		return
	var 目录 := DirAccess.open(目录路径)
	if 目录 == null:
		return
	
	目录.list_dir_begin()
	var 遍历文件名 := 目录.get_next()
	while 遍历文件名 != "":
		if 目录.current_is_dir():
			if not 遍历文件名.begins_with("."):
				收集pck(目录路径.path_join(遍历文件名), 剩余层数 - 1)
		elif 遍历文件名.ends_with(".pck") or 遍历文件名.ends_with(".zip"):
			pck文件字典[遍历文件名] = 目录路径.path_join(遍历文件名)
		遍历文件名 = 目录.get_next()
	目录.list_dir_end()


func 扫描mods项目文件夹() -> void:
	if not DirAccess.dir_exists_absolute(mods项目文件夹路径):
		return
	var mods目录 = DirAccess.open(mods项目文件夹路径)
	if mods目录 == null:
		return
	
	mods目录.list_dir_begin()
	var 遍历mod项目名 = mods目录.get_next()
	while 遍历mod项目名 != "":
		if mods目录.current_is_dir() and not 遍历mod项目名.begins_with("."):
			mod项目字典[遍历mod项目名] = null
		遍历mod项目名 = mods目录.get_next()
	mods目录.list_dir_end()
	
	return

func 加载单个mod(mod项目名 : String) -> void:
	var mod项目路径 = mods项目文件夹路径.path_join(mod项目名)
	
	# 在 root 下创建 mod 根节点
	var mod根节点 = Node.new()
	mod根节点.name = 节点名处理(mod项目名)
	self.add_child(mod根节点)
	mod项目字典[mod项目名] = mod根节点
	
	# 扫描 AutoLoad 目录并实例化脚本
	var 自动加载路径 = mod项目路径.path_join(自动加载目录名)
	实例化自动加载脚本(mod根节点, 自动加载路径)
	
	print("[mod管理] mod项目加载完成「%s」" % mod项目路径)

func 实例化自动加载脚本(指定mod根节点 : Node, 自动加载路径 : String) -> void:
	if not DirAccess.dir_exists_absolute(自动加载路径):
		print("[mod管理] mod项目中没有 AutoLoad 目录「%s」，仅挂载资源" % 自动加载路径)
		return 
	
	var 目录 = DirAccess.open(自动加载路径)
	if 目录 == null:
		print("[mod管理] mod项目中 AutoLoad 目录「%s」出错" % 自动加载路径)
		return 
	
	var 脚本路径字典: Dictionary = {}
	
	目录.list_dir_begin()
	var 文件名 := 目录.get_next()
	while 文件名 != "":
		if not 目录.current_is_dir():
			# ========== 情况 A：Text 模式（Export Preset → Script 选 "Text"）==========
			# mod 包里直接是 .gd 源文件，load() 直接命中
			if 文件名.ends_with(".gd"):
				脚本路径字典[自动加载路径.path_join(文件名)] = true
			# ========== 情况 B：Binary tokens 模式（默认的 Compressed binary tokens）==========
			# mod 包里只有 .gd.remap + 隐藏命名的 .gdc
			# .remap 是"源 .gd 路径 → .gdc 实际文件"的映射
			# load(源 .gd 路径) 时 ResourceLoader 自动通过 .remap 找到 .gdc
			elif 文件名.ends_with(".gd.remap"):
				# 文件名 "修改初始生命值.gd.remap" → 去 .remap → "修改初始生命值.gd"
				var 源gd文件名 = 文件名.trim_suffix(".remap")
				脚本路径字典[自动加载路径.path_join(源gd文件名)] = true
		文件名 = 目录.get_next()
	目录.list_dir_end()

	for 脚本路径 in 脚本路径字典.keys():
		var 脚本 : Script = load(脚本路径)
		if 脚本 == null:
			print("[mod管理] 无法加载脚本：" + 脚本路径)
			continue

		var 实例 = 脚本.new()
		if 实例 is Node:
			# 节点名：脚本路径的 basename（去 .gd 后缀）
			# 两种模式下的"源 .gd 路径"完全一样，所以 trim_suffix(".gd") 都正确
			var 节点名 = 脚本路径.get_file().trim_suffix(".gd")
			实例.name = 节点名
			指定mod根节点.add_child(实例)
			print("[mod管理] Node 脚本：%s（已经实例化）" % 脚本路径)
		else:
			# 非 Node 脚本不是合法 AutoLoad，跳过（引用计数自动回收）
			print("[mod管理] 跳过非 Node 脚本：%s（AutoLoad 必须 extends Node）" % 脚本路径)
	
	return

func 节点名处理(原始名 : String) -> String:
	var 基础名 = 净化节点名(原始名)
	var 最终名 = 基础名
	var 序号 = 2
	while mod根节点名称字典.has(最终名):
		最终名 = "%s%d" % [基础名, 序号]
		序号 += 1
	mod根节点名称字典[最终名] = true
	return 最终名

func 净化节点名(原始名 : String) -> String:
	# 节点名不能包含 / : @ . 等字符，也不能以数字开头
	var 净化后 := ""
	for 字符 in 原始名:
		if 字符 in ["/", ":", "@", ".", "\"", "%", "#", "&", " ", "(", ")", "（", "）"]:
			continue
		净化后 += 字符
	if 净化后 == "":
		净化后 = "Mod"
	return 净化后
