extends Control
class_name TimelineList

@export var panel: PackedScene = preload("res://timeline_panel.tscn")

@onready var panel_container: VBoxContainer = %PanelContainer

const RECORDS_PATH = "user://records"

func _ready() -> void:
	var records = DirAccess.get_files_at(RECORDS_PATH)
	records.reverse()
	for record in records:
		var filepath = RECORDS_PATH + "/" + record
		var date = record.split(".")[0]
		# print(filepath)
		var panel_instance: TimelinePanel = panel.instantiate()
		panel_container.add_child(panel_instance)  # 这样能让他@onready的东西生效
		if not panel_instance.load_timeline(filepath, date):
			panel_instance.queue_free()
