extends Control
class_name Main

@onready var timers = %TimersContainer

const PORT := 58734
const SERVER_IP := "127.0.0.1"

var filename: String
var record: Record  # 客户端中可能为空
# var brief_record: BriefRecord
var is_new_record: bool = false

var previous_date: String

func is_run_in_server_mode():
	return OS.has_feature("editor") or "--server" in OS.get_cmdline_user_args()
	# return true

func _ready() -> void:
	# print("display scale: %s" % DisplayServer.screen_get_scale())
	if is_run_in_server_mode():
		print("running as server")
		var peer := ENetMultiplayerPeer.new()
		peer.create_server(PORT)
		multiplayer.multiplayer_peer = peer
	else:
		print("running as client")
		var peer := ENetMultiplayerPeer.new()
		peer.create_client(SERVER_IP, PORT)
		multiplayer.multiplayer_peer = peer

	for timer: TimerButton in timers.get_children():
		timer.clicked.connect(_on_timer_button_clicked)

	if multiplayer.is_server():
		server_load_record()

	Metronome.tick.connect(tick)

	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func server_load_record() -> void:
	load_record()

	# 让服务端自己以及已连接的客户端重新加载
	var brief_record: BriefRecord = record.get_brief()
	read_brief_record.rpc(brief_record.to_dict())

# 将record存在类变量中
func load_record():
	# 确保records文件夹存在
	DirAccess.make_dir_absolute("user://records")

	# 读取或创建今天的记录
	var date: String = Time.get_date_string_from_system()
	previous_date = date
	filename = "user://records/%s.res" % date
	# var time_dict: Dictionary = Time.get_time_dict_from_system()
	# filename = "user://records/%s_%s-%s.res" % [date, time_dict["hour"], time_dict["minute"]]
	print("filename: %s" % filename)

	if FileAccess.file_exists(filename):
		record = Record.load_from(filename)
		is_new_record = false
	else:
		record = Record.new()
		record.save_to(filename)
		is_new_record = true


@rpc("authority", "call_local", "reliable")
func read_brief_record(brief_record_dict: Dictionary) -> void:
	var brief_record = BriefRecord.from_dict(brief_record_dict)
	var total_times: Dictionary = brief_record.total_times

	# 为每个定时器分配类型，设置时间，并监听点击事件
	var type = 1
	for timer: TimerButton in timers.get_children():
		timer.type = type
		timer.set_color(Palette.get_color(type))
		type += 1
		if timer.type in total_times:
			timer.cumulative_time = total_times[timer.type]
		else:
			timer.cumulative_time = 0

	# 找到当前是哪个计时器处于激活状态
	var active_timer_button: TimerButton
	if brief_record.is_empty:
		# 默认第一个处于激活状态
		active_timer_button = timers.get_child(0)
	else:
		# 根据最后一个记录来决定
		var last_type: int = brief_record.last_activated_type
		for timer: TimerButton in timers.get_children():
			if timer.type == last_type:
				active_timer_button = timer
				break
	
	# 先禁用掉所有计时器
	for timer: TimerButton in timers.get_children():
		timer.button_pressed = false

	# 激活最后使用的计时器，并让它知道上次点击的时间
	active_timer_button.button_pressed = true
	active_timer_button.last_timestamp = brief_record.last_timestamp

	# 更新所有计时器
	for timer: TimerButton in timers.get_children():
		timer.update_time()


func tick(seconds: int):
	# 更新所有计时器
	for timer: TimerButton in timers.get_children():
		timer.update_time()

	if multiplayer.is_server():
		# 每分钟将记录写入磁盘
		if seconds % 60 == 0:
			record.save_to(filename)

		# 如果到了新的一天，重新加载
		if previous_date != Time.get_date_string_from_system():
			print("new day")
			server_load_record()

func _exit_tree() -> void:
	if multiplayer.is_server():
		# 退出时保存记录
		record.save_to(filename)

func _on_timer_button_clicked(timer_button: TimerButton):
	server_change_timer.rpc_id(1, timer_button.type)

@rpc("any_peer", "call_local", "reliable")
func server_change_timer(timer_type: int) -> void:
	if not multiplayer.is_server():
		return

	# 如果点击的是当前激活的计时器，不做任何操作
	if record.size() > 0 and record.peek().type == timer_type:
		return

	# 添加一条新的记录
	var new_record: Entry = Entry.new()
	new_record.type = timer_type
	new_record.timestamp = Metronome.last_seconds
	record.push(new_record)

	# 让服务端自己以及已连接的客户端重新加载
	var brief_record: BriefRecord = record.get_brief()
	read_brief_record.rpc(brief_record.to_dict())

func _on_player_connected(id: int) -> void:
	print("Player connected with id: %d" % id)
	if multiplayer.is_server():
		var brief_record: BriefRecord = record.get_brief()
		read_brief_record.rpc_id(id, brief_record.to_dict())

func _on_player_disconnected(id: int) -> void:
	print("Player disconnected with id: %d" % id)

func _on_connected_ok() -> void:
	print("Successfully connected to server")

func _on_connected_fail() -> void:
	print("Failed to connect to server")
	get_tree().quit()

func _on_server_disconnected() -> void:
	print("Server disconnected")
	get_tree().quit()