extends Control
class_name Main

@onready var timers = %TimersContainer

const PORT := 58734
const SERVER_IP := "127.0.0.1"

var filename: String
var record: Record  # 客户端中可能为空
# var brief_record: BriefRecord

var previous_date: String

func _ready() -> void:
	# print("display scale: %s" % DisplayServer.screen_get_scale())
	if Globals.is_run_in_server_mode():
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

	var udp_api := UdpApi.new()
	udp_api.number_received.connect(_on_udp_api_number_received)
	add_child(udp_api)

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
func load_record() -> void:
	# 确保records文件夹存在
	DirAccess.make_dir_absolute(Globals.get_records_folder())

	# 读取或创建今天的记录
	var date: String = Metronome.get_date_string()
	previous_date = date
	filename = Globals.get_records_file_path("%s.json" % date)
	# var time_dict: Dictionary = Time.get_time_dict_from_system()
	# filename = Globals.get_records_file_path("%s_%s-%s.json" % [date, time_dict["hour"], time_dict["minute"]])
	print("filename: %s" % filename)

	if FileAccess.file_exists(filename):
		record = Record.load_from(filename)
	else:
		var new_record = Record.new()

		# 我们在t=0s创建一条记录
		# 如果目前没有已加载的记录，说明现在是程序刚启动，我们使用默认的计时器类型
		# 否则，使用当前激活的计时器的类型
		var begin_timer_name: String
		if record == null:
			begin_timer_name = TimerTypeList.at(TimerTypeList.default_type_index).timer_name
		else:
			begin_timer_name = record.peek().timer_name

		var new_entry: Entry = Entry.new()
		new_entry.timestamp = 0
		new_entry.timer_name = begin_timer_name
		new_record.push(new_entry)

		record = new_record
		record.save_to(filename)


@rpc("authority", "call_local", "reliable")
func read_brief_record(brief_record_dict: Dictionary) -> void:
	var brief_record = BriefRecord.from_dict(brief_record_dict)
	var total_times: Dictionary = brief_record.total_times

	# 为每个定时器分配类型，设置时间，并监听点击事件
	var index = TimerTypeList.default_type_index
	for timer: TimerButton in timers.get_children():
		timer.index = index
		var timer_type := TimerTypeList.at(index)
		timer.timer_name = timer_type.timer_name
		timer.set_color(timer_type.color)
		index += 1
		if timer.timer_name in total_times:
			timer.cumulative_time = total_times[timer.timer_name]
		else:
			timer.cumulative_time = 0

	# 找到当前是哪个计时器处于激活状态
	var active_timer_button: TimerButton
	if brief_record.is_empty:
		# 使用TimerTypeList中记录的默认的第几个
		for timer: TimerButton in timers.get_children():
			if timer.timer_name == TimerTypeList.at(TimerTypeList.default_type_index).timer_name:
				active_timer_button = timer
				break

		# TODO: 处理没有匹配项的情况

	else:
		# 根据最后一个记录来决定
		var activated_name: String = brief_record.last_activated_name
		for timer: TimerButton in timers.get_children():
			if timer.timer_name == activated_name:
				active_timer_button = timer
				break
	
	# 先禁用掉所有计时器
	for timer: TimerButton in timers.get_children():
		timer.button_pressed = false

	# 设置各个计时器的激活状态
	# active_timer_button.button_pressed = true
	for timer: TimerButton in timers.get_children():
		if timer == active_timer_button:
			timer.remote_press()
		else:
			timer.remote_release()

	# 让最后使用的计时器知道上次点击的时间
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
		if previous_date != Metronome.get_date_string():
			print("\nNew day: %s" % Metronome.get_date_string())
			server_load_record()

func _exit_tree() -> void:
	if multiplayer.is_server():
		# 退出时保存记录
		record.save_to(filename)

func _on_timer_button_clicked(timer_pressed: TimerButton):
	for timer: TimerButton in timers.get_children():
		if timer != timer_pressed:
			timer.local_release()

	server_change_timer.rpc_id(1, timer_pressed.timer_name, Metronome.seconds)

func _on_udp_api_number_received(number: int) -> void:
	for timer: TimerButton in timers.get_children():
		if timer.index == number:
			timer.local_press()

@rpc("any_peer", "call_local", "reliable")
func server_change_timer(timer_name: String, seconds_on_request: int) -> void:
	if not multiplayer.is_server():
		return

	# 如果点击的是当前激活的计时器，不做任何操作
	if record.size() > 0 and record.peek().timer_name == timer_name:
		return

	# 添加一条新的记录
	var new_record: Entry = Entry.new()
	new_record.timer_name = timer_name
	new_record.timestamp = seconds_on_request
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