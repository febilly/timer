extends Button
class_name TimerButton

signal clicked(timer_button: TimerButton)

@export var type: int = 1:
	set(v):
		# print(shortcut.events[0])
		type = v
		shortcut.events[0].keycode = 48 + v
		shortcut.events[1].keycode = 4194438 + v
@export var type_name: String = "任务名"

@export var base_style_box: StyleBoxFlat = preload("res://button.tres")
@export var base_color: Color = Color.from_hsv(0.56, 0.9, 0.8)

@onready var labels: Control = $Labels
@onready var time_label: Label = $Labels/TimeLabel
@onready var name_label: Label = $Labels/NameLabel

var cumulative_time: int = 0
var last_timestamp: int = 0


func _ready() -> void:
	# _set_color(base_color)
	name_label.text = type_name

func _process(delta: float) -> void:
	update_labels()

# 由main.gd调用
func update_time() -> void:
	var total_sec: int = cumulative_time
	if button_pressed:
		total_sec += Metronome.last_seconds - last_timestamp

	var seconds: int = total_sec % 60
	var minutes: int = (total_sec / 60) % 60
	var hours: int = total_sec / 3600
	time_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]

func update_labels() -> void:
	for label: Label in labels.get_children():
		if button_pressed:
			label.label_settings.font_color = Color.WHITE
		else:
			label.label_settings.font_color = Color.DIM_GRAY

		if label is ResponsiveLabel:
			label = label as ResponsiveLabel
			label.update_font_size(size)

func set_color(color: Color) -> void:
	_set_color(color)
	base_color = color

func _set_color(color: Color) -> void:
	var style_box

	begin_bulk_theme_override()

	var normal_color: Color = color
	normal_color.s *= 0.4
	normal_color.v *= 0.25
	style_box = base_style_box.duplicate()
	style_box.bg_color = normal_color
	add_theme_stylebox_override("normal", style_box)
	
	var hover_color: Color = color
	hover_color.s *= 0.4
	hover_color.v *= 0.2
	style_box = base_style_box.duplicate()
	style_box.bg_color = hover_color
	add_theme_stylebox_override("hover", style_box)
	
	var pressed_color: Color = color
	pressed_color.v *= 0.8
	style_box = base_style_box.duplicate()
	style_box.bg_color = pressed_color
	add_theme_stylebox_override("pressed", style_box)
	add_theme_stylebox_override("hover_pressed", style_box)

	end_bulk_theme_override()   

func get_random_color() -> Color:
	return Color.from_hsv(randf(), 0.9, 0.8)

func _on_pressed() -> void:
	clicked.emit(self)
	flash()

func flash() -> void:
	_set_color(Color.BLACK)
	labels.hide()
	await get_tree().create_timer(0.05, false).timeout
	_set_color(Color.WHITE)
	await get_tree().create_timer(0.05, false).timeout
	# _set_color(Color.BLACK)
	# await get_tree().create_timer(0.05, false).timeout
	_set_color(base_color)
	labels.show()
