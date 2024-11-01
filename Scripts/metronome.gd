extends Node

signal tick(seconds: int)
signal time_synced()

var seconds := get_seconds_of_the_day()

var offset_sec: float = 0
var request_start_timestamp: float = 0

func _ready() -> void:
	# multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_ok)

func _process(delta: float) -> void:
	var new_seconds = get_seconds_of_the_day()
	if new_seconds != seconds:
		seconds = new_seconds
		tick.emit(new_seconds)


func get_seconds_of_the_day() -> int:
	var timestamp: float = Time.get_unix_time_from_system()

	var timezone_dict = Time.get_time_zone_from_system()
	timestamp += timezone_dict["bias"] * 60

	timestamp += offset_sec

	var timestamp_int = int(timestamp)
	timestamp_int %= 86400

	return timestamp_int

func _on_connected_ok() -> void:
	if not multiplayer.is_server():
		request_sync()

# 客户端在本地调用此函数，向服务端请求进行同步，同时测量往返延迟，取一半作为估计的单向传播延迟
func request_sync() -> void:
	print("request_sync")
	request_start_timestamp = Time.get_unix_time_from_system()
	handle_sync_request.rpc_id(1)

# 服务端接收到客户端的同步请求后，返回当前时间戳（调用客户端的receive_sync）
@rpc("any_peer", "call_remote", "reliable", 1)
func handle_sync_request() -> void:
	print("handle_sync_request - Client ID: %d" % multiplayer.get_remote_sender_id())
	var server_timestamp = Time.get_unix_time_from_system()
	receive_sync.rpc_id(multiplayer.get_remote_sender_id(), server_timestamp)

# 服务端调用客户端的此函数，告知客户端当前时间戳
@rpc("authority", "call_remote", "reliable", 1)
func receive_sync(server_timestamp: float) -> void:
	var now = Time.get_unix_time_from_system()
	var ping = now - request_start_timestamp
	var half_trip_delay = ping / 2
	var real_server_timestamp = server_timestamp + half_trip_delay
	offset_sec = real_server_timestamp - now
	print("receive_sync - ping: %f" % ping)
	print("receive_sync - offset_sec: %f" % offset_sec)
	time_synced.emit()
