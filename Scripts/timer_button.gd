extends Button
class_name TimerButton

signal clicked(timer_button: TimerButton)

@export var index: int = 0:
	set(v):
		# print(shortcut.events[0])
		index = v
		shortcut.events[0].keycode = 48 + v + 1
		shortcut.events[1].keycode = 4194438 + v + 1
@export var timer_name: String = "Name":
	set(v):
		timer_name = v
		if name_label:
			name_label.text = v

@export var base_style_box: StyleBoxFlat = preload("res://button.tres")
@export var base_color: Color = Color.from_hsv(0.56, 0.9, 0.8)

@onready var labels: Control = $Labels
@onready var total_time_label: Label = $Labels/TotalTimeLabel
@onready var this_time_label: Label = $Labels/ThisTimeLabel
@onready var name_label: Label = $Labels/NameLabel

var cumulative_time: int = 0  # 之前已经计时的时间，不包含此次按下以来经过的时间（如果现在已经被按下）
var last_timestamp: int = 0  # 最近一次按下的时间戳

var was_pressed: bool = false

func _ready() -> void:
	# _set_color(base_color)
	name_label.text = timer_name

func _process(delta: float) -> void:
	update_labels()
	was_pressed = button_pressed

# 由main.gd调用
func update_time() -> void:
	var total_sec: int = cumulative_time
	var elapsed_sec: int = Metronome.seconds - last_timestamp
	if button_pressed:
		total_sec += elapsed_sec

	var total_seconds: int = total_sec % 60
	var total_minutes: int = (total_sec / 60) % 60
	var total_hours: int = total_sec / 3600
	total_time_label.text = "%02d:%02d:%02d" % [total_hours, total_minutes, total_seconds]
	
	if button_pressed:
		var this_seconds: int = elapsed_sec % 60
		var this_minutes: int = (elapsed_sec / 60) % 60
		var this_hours: int = elapsed_sec / 3600
		this_time_label.text = "%02d:%02d:%02d" % [this_hours, this_minutes, this_seconds]
	else:
		this_time_label.text = "00:00:00"


func update_labels() -> void:
	for label: Label in labels.get_children():
		# 更新字体颜色
		if button_pressed:
			label.label_settings.font_color = Color.WHITE
		else:
			label.label_settings.font_color = Color.DIM_GRAY

		# 更新标签大小
		if label is ResponsiveLabel:
			label = label as ResponsiveLabel
			label.update_font_size(size)

	# 如果此计时器处于激活状态，显示此次计时的时间
	this_time_label.visible = button_pressed

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
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		hover_color.v *= 0.25
	else:
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
	local_press()

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

func local_press() -> void:
	# button_pressed = true

	if not was_pressed:
		last_timestamp = Metronome.seconds

	clicked.emit(self)
	flash()

func local_release() -> void:
	if button_pressed:
		button_pressed = false
		cumulative_time += Metronome.seconds - last_timestamp
		
func remote_press() -> void:
	button_pressed = true
	pass

func remote_release() -> void:
	button_pressed = false
	pass
