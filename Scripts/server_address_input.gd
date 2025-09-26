extends Control

@onready var address_line = %AddressLine
@onready var connect_button = %ConnectButton

# Called when the node enters the scene tree for the first time.
func _ready():
	var config_path = Globals.get_data_file_path("server_address.txt")
	if FileAccess.file_exists(config_path):
		var file := FileAccess.open(config_path, FileAccess.ModeFlags.READ)
		address_line.text = file.get_as_text()
		file.close()
	else:
		var file := FileAccess.open(config_path, FileAccess.ModeFlags.WRITE)
		address_line.text = "localhost"
		file.store_string(address_line.text)
		file.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
