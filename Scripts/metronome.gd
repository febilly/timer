extends Node

signal tick(seconds: int)
signal time_synced()

const debug_time_offset_config = "time_offset.json"

var seconds := get_seconds_of_the_day()

var sync_offset_sec: float = 0
var debug_offset_sec: float = 0
var request_start_timestamp: float = 0

func _ready() -> void:
	# multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_ok)

	if Globals.is_debugging_time_offset():
		debug_offset_sec = get_debug_time_offset()

func _process(delta: float) -> void:
	var new_seconds = get_seconds_of_the_day()
	if new_seconds != seconds:
		seconds = new_seconds
		tick.emit(new_seconds)

		if Globals.is_debugging_time_offset():
			debug_offset_sec = get_debug_time_offset()

func get_debug_time_offset() -> float:
	if not Globals.is_run_in_server_mode():
		printerr("get_debug_time_offset is only supported on server")
		return 0.0

	var config_file_path = Globals.get_data_file_path(debug_time_offset_config)
	if not FileAccess.file_exists(config_file_path):
		printerr("File not found: %s" % config_file_path)
		return 0.0
	
	var file := FileAccess.open(config_file_path, FileAccess.ModeFlags.READ)
	var file_content = file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(file_content)
	if error != OK:
		printerr("Failed to parse JSON file: %s" % debug_time_offset_config)
		return 0.0
	
	var offset = json.data["offset"]
	if offset == null or (offset is not float and offset is not int):
		printerr("Failed to get offset from JSON file: %s" % debug_time_offset_config)
		return 0.0
	
	return offset

func get_timestamp(use_offset: bool) -> float:
	var timestamp: float = Time.get_unix_time_from_system()

	if use_offset:
		timestamp += sync_offset_sec

	if Globals.is_debugging_time_offset():
		timestamp += debug_offset_sec

	return timestamp

func get_seconds_of_the_day() -> int:
	var timestamp: float = get_timestamp(true)

	var timezone_dict = Time.get_time_zone_from_system()
	timestamp += timezone_dict["bias"] * 60

	var timestamp_int = int(timestamp)
	timestamp_int %= 86400

	return timestamp_int

func get_date_string() -> String:
	var timestamp := get_timestamp(true)

	# 这里我们需要手动加上时区偏移
	# 我读了源码，发现Time.get_date_string_from_unix_time不考虑时区...
	var timezone_dict = Time.get_time_zone_from_system()
	timestamp += timezone_dict["bias"] * 60

	return Time.get_date_string_from_unix_time(timestamp)
	

func _on_connected_ok() -> void:
	if not multiplayer.is_server():
		request_sync()

# 客户端在本地调用此函数，向服务端请求进行同步，同时测量往返延迟，取一半作为估计的单向传播延迟
func request_sync() -> void:
	print("request_sync")
	request_start_timestamp = get_timestamp(false)
	handle_sync_request.rpc_id(1)

# 服务端接收到客户端的同步请求后，返回当前时间戳（调用客户端的receive_sync）
@rpc("any_peer", "call_remote", "reliable", 1)
func handle_sync_request() -> void:
	print("handle_sync_request - Client ID: %d" % multiplayer.get_remote_sender_id())
	var server_timestamp = get_timestamp(false)
	receive_sync.rpc_id(multiplayer.get_remote_sender_id(), server_timestamp)

# 服务端调用客户端的此函数，告知客户端当前时间戳
@rpc("authority", "call_remote", "reliable", 1)
func receive_sync(server_timestamp: float) -> void:
	var now = get_timestamp(false)
	var ping = now - request_start_timestamp
	var half_trip_delay = ping / 2
	var real_server_timestamp = server_timestamp + half_trip_delay
	sync_offset_sec = real_server_timestamp - now
	print("receive_sync - ping: %f" % ping)
	print("receive_sync - sync_offset_sec: %f" % sync_offset_sec)
	time_synced.emit()
