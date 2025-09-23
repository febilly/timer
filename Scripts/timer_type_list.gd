extends Resource
class_name TimerTypeList

const CONFIG_FILE_NAME := "timer_types.json"

const default_color := Color.SKY_BLUE
static var default_type_index := 0

static var list: Array[TimerType] = []
static var _config_file_path: String = ""
static var _last_modified_time: int = 0
static var _is_initialized: bool = false

static func initialize() -> void:
	if _is_initialized:
		return
	
	_is_initialized = true
	load_from_config()

static func check_for_config_changes() -> bool:
	# 只在服务端检查配置文件变化
	if not Globals.is_run_in_server_mode():
		return false
		
	if _config_file_path.is_empty():
		return false
	
	if not FileAccess.file_exists(_config_file_path):
		return false
	
	var current_modified_time := FileAccess.get_modified_time(_config_file_path)
	
	if current_modified_time != _last_modified_time:
		_last_modified_time = current_modified_time
		return true
	
	return false

static func reload_if_changed() -> bool:
	# 只在服务端检查和重载配置文件
	if not Globals.is_run_in_server_mode():
		return false
		
	if check_for_config_changes():
		print("Config file changed, reloading timer types...")
		load_from_config()
		return true
	return false

static func load_from_config() -> void:
	_config_file_path = get_config_file_path()
	
	# 如果配置文件不存在，创建默认配置文件
	if not FileAccess.file_exists(_config_file_path):
		create_default_config_file(_config_file_path)
	
	# 更新最后修改时间
	_last_modified_time = FileAccess.get_modified_time(_config_file_path)
	
	var file := FileAccess.open(_config_file_path, FileAccess.READ)
	if file == null:
		printerr("Failed to open config file: %s" % _config_file_path)
		load_default_types()
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	if error != OK:
		printerr("Failed to parse JSON config file: %s" % _config_file_path)
		load_default_types()
		return
	
	var config_data: Dictionary = json.data
	
	# 解析计时器类型列表
	list.clear()
	if "timer_types" in config_data and config_data["timer_types"] is Array:
		for timer_data in config_data["timer_types"]:
			if timer_data is Dictionary and "name" in timer_data and "color" in timer_data:
				var timer_type := TimerType.create(timer_data["name"], Color(timer_data["color"]))
				list.append(timer_type)
	
	# 解析默认类型索引
	if "default_type_index" in config_data and config_data["default_type_index"] is int:
		default_type_index = config_data["default_type_index"]
	else:
		default_type_index = 0
	
	# 如果没有加载到任何类型，使用默认类型
	if list.is_empty():
		load_default_types()
	
	print("Loaded %d timer types from config file: %s" % [list.size(), _config_file_path])

static func get_config_file_path() -> String:
	# 首先尝试从可执行文件同目录下读取
	var exe_dir := OS.get_executable_path().get_base_dir()
	var external_config_path := exe_dir + "/" + CONFIG_FILE_NAME
	
	# 如果外部配置文件存在，使用外部配置文件
	if FileAccess.file_exists(external_config_path):
		return external_config_path
	
	# 否则使用用户数据目录下的配置文件
	return Globals.get_data_file_path(CONFIG_FILE_NAME)

static func create_default_config_file(config_path: String) -> void:
	var default_config := {
		"timer_types": [
			{"name": "摸鱼", "color": "#ff004d"},
			{"name": "看视频", "color": "#ff77a8"},
			{"name": "刷手机", "color": "#ffa300"},
			{"name": "学东西", "color": "#ffec27"},
			{"name": "写课程作业", "color": "#66dd3a"},
			{"name": "打游戏", "color": "#4dffea"},
			{"name": "研究生", "color": "#297bff"},
			{"name": "做东西", "color": "#bb29ff"}
		],
		"default_type_index": 0
	}
	
	var file := FileAccess.open(config_path, FileAccess.WRITE)
	if file == null:
		printerr("Failed to create default config file: %s" % config_path)
		return
	
	file.store_string(JSON.stringify(default_config, "\t"))
	file.close()
	print("Created default config file: %s" % config_path)

static func load_default_types() -> void:
	list.clear()
	list.append_array([
		TimerType.create("摸鱼", Color("#ff004d")),
		TimerType.create("看视频", Color("#ff77a8")),
		TimerType.create("刷手机", Color("#ffa300")),
		TimerType.create("学东西", Color("#ffec27")),
		TimerType.create("写课程作业", Color("#66dd3a")),
		TimerType.create("打游戏", Color("#4dffea")),
		TimerType.create("研究生", Color("#297bff")),
		TimerType.create("做东西", Color("#bb29ff"))
	])
	default_type_index = 0

static func at(index: int) -> TimerType:
	if list.is_empty():
		load_default_types()
	return list[index % list.size()]

static func has_timer_name(name: String) -> bool:
	for timer_type in list:
		if timer_type.timer_name == name:
			return true
	return false

static func get_color(name: String) -> Color:
	for timer_type in list:
		if timer_type.timer_name == name:
			return timer_type.color
	return default_color

# 序列化为字典（用于网络传输）
static func to_dict() -> Dictionary:
	var data := Dictionary()
	data["default_type_index"] = default_type_index
	data["timer_types"] = []
	
	for timer_type in list:
		data["timer_types"].append({
			"name": timer_type.timer_name,
			"color": timer_type.color.to_html()
		})
	
	return data

# 从字典加载（用于网络接收）
static func from_dict(data: Dictionary) -> void:
	list.clear()
	
	# 解析计时器类型列表
	if "timer_types" in data and data["timer_types"] is Array:
		for timer_data in data["timer_types"]:
			if timer_data is Dictionary and "name" in timer_data and "color" in timer_data:
				var timer_type := TimerType.create(timer_data["name"], Color(timer_data["color"]))
				list.append(timer_type)
	
	# 解析默认类型索引
	if "default_type_index" in data and data["default_type_index"] is int:
		default_type_index = data["default_type_index"]
	else:
		default_type_index = 0
	
	# 如果没有加载到任何类型，使用默认类型
	if list.is_empty():
		load_default_types()
	
	print("Loaded %d timer types from network data" % list.size())