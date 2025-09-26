extends Control 

@export var main_scene: PackedScene = preload("res://main.tscn")

@onready var connect_button = %ConnectButton

# 获取三个服务器容器的引用
@onready var server1_container = $ColorRect/VBoxContainer/Server1
@onready var server2_container = $ColorRect/VBoxContainer/Server2
@onready var server3_container = $ColorRect/VBoxContainer/Server3

# 服务器配置数据结构
var server_config = {
	"servers": [
		{"address": "localhost", "selected": true},
		{"address": "127.0.0.1", "selected": false},
		{"address": "[::1]", "selected": false}
	],
	"last_selected": 0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	# 如果是服务器模式，直接跳转到主场景
	if Globals.is_run_in_server_mode():
		get_tree().change_scene_to_packed(main_scene)
		return
	
	load_config()
	connect_button.pressed.connect(_on_connect_button_pressed)
	
	# 为每个服务器的输入框连接文本变化信号
	var server_containers = [server1_container, server2_container, server3_container]
	for i in range(server_containers.size()):
		var line_edit = server_containers[i].get_node("AddressLine")
		var checkbox = server_containers[i].get_node("CheckBox")
		
		# 连接文本变化信号
		line_edit.text_changed.connect(_on_address_changed.bind(i))
		# 连接选择变化信号
		checkbox.toggled.connect(_on_server_selected.bind(i))

func load_config():
	var config_path = Globals.get_data_file_path("server_config.json")
	if FileAccess.file_exists(config_path):
		var file := FileAccess.open(config_path, FileAccess.ModeFlags.READ)
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			server_config = json.data
		else:
			print("Failed to parse server config JSON")
	else:
		# 创建默认配置文件
		save_config()
	
	# 更新UI
	update_ui()

func save_config():
	var config_path = Globals.get_data_file_path("server_config.json")
	var file := FileAccess.open(config_path, FileAccess.ModeFlags.WRITE)
	var json_string = JSON.stringify(server_config)
	file.store_string(json_string)
	file.close()

func update_ui():
	var server_containers = [server1_container, server2_container, server3_container]
	
	for i in range(server_containers.size()):
		var line_edit = server_containers[i].get_node("AddressLine")
		var checkbox = server_containers[i].get_node("CheckBox")
		
		# 更新地址
		if i < server_config.servers.size():
			line_edit.text = server_config.servers[i].address
			checkbox.button_pressed = server_config.servers[i].selected
		else:
			line_edit.text = ""
			checkbox.button_pressed = false

func _on_address_changed(new_text: String, server_index: int):
	if server_index < server_config.servers.size():
		server_config.servers[server_index].address = new_text

func _on_server_selected(button_pressed: bool, server_index: int):
	if button_pressed:
		# 更新选中状态
		for i in range(server_config.servers.size()):
			server_config.servers[i].selected = (i == server_index)
		
		server_config.last_selected = server_index

func _on_connect_button_pressed():
	var selected_address = get_selected_server_address()
	if selected_address != "":
		save_config()

		print("Connecting to server: %s" % selected_address)
		Globals.server_ip = selected_address

		get_tree().change_scene_to_packed(main_scene)
	else:
		print("No server selected!")

func get_selected_server_address() -> String:
	for server in server_config.servers:
		if server.selected:
			return server.address
	return ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
