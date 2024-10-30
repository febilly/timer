extends Control
class_name Main

@onready var timers = %TimersContainer

var filename: String
var record: Record
var is_new_record: bool = false

func _ready() -> void:
    # print("display scale: %s" % DisplayServer.screen_get_scale())
    load_record()

    Metronome.tick.connect(tick)

func load_record() -> void:
    # 确保records文件夹存在
    DirAccess.make_dir_absolute("user://records")

    # 读取或创建今天的记录
    var date: String = Time.get_date_string_from_system()
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

    # 为每个定时器分配类型，设置时间，并监听点击事件
    var total_times: Dictionary = record.get_total_times()
    var type = 1
    for timer: TimerButton in timers.get_children():
        timer.clicked.connect(_on_timer_button_clicked)
        timer.type = type
        timer.set_color(Palette.get_color(type))
        type += 1
        if timer.type in total_times:
            timer.set_time(total_times[timer.type])
        else:
            timer.set_time(0)

    # 找到当前是哪个计时器处于激活状态
    var active_timer_button: TimerButton
    if record.size() == 0:
        # 默认第一个处于激活状态
        active_timer_button = timers.get_child(0)
    else:
        # 根据最后一个记录来决定
        var last_type: int = record.peek().type
        for timer: TimerButton in timers.get_children():
            if timer.type == last_type:
                active_timer_button = timer
                break
    
    # 激活最后使用的计时器，并把从最后一次记录到目前为止的时间给它加上
    active_timer_button.button_pressed = true
    if record.size() == 0:
        active_timer_button.cumulative_time += Metronome.last_seconds
    else:
        active_timer_button.cumulative_time += Metronome.last_seconds - record.peek().timestamp


func tick(seconds: int):
    # 每分钟将记录写入磁盘
    if seconds % 60 == 0:
        # print("save record")
        record.save_to(filename)
        # load_record()

    # 如果到了新的一天，重新加载
    if seconds == 0:
        load_record()

func _exit_tree() -> void:
    # 退出时保存记录
    record.save_to(filename)

func _on_timer_button_clicked(timer_button: TimerButton):
    # 如果点击的是当前激活的计时器，不做任何操作
    if record.size() > 0 and record.peek().type == timer_button.type:
        return
    
    # 添加一条新的记录
    var new_record: Entry = Entry.new()
    new_record.type = timer_button.type
    new_record.timestamp = Metronome.last_seconds
    record.push(new_record)
