extends Resource
class_name TimerTypeList

const default_color := Color.SKY_BLUE
const default_type_index := 0

static var list: Array[TimerType] = [
	TimerType.create("摸鱼", Color("#ff004d")),
	TimerType.create("看视频", Color("#ff77a8")),
	TimerType.create("刷手机", Color("#ffa300")),
	TimerType.create("学东西", Color("#ffec27")),
	TimerType.create("写课程作业", Color("#66dd3a")),
	TimerType.create("打游戏", Color("#4dffea")),
	TimerType.create("研究生", Color("#297bff")),
	TimerType.create("做东西", Color("#bb29ff")),
]

static func at(index: int) -> TimerType:
	return list[index % list.size()]

static func get_color(name: String) -> Color:
	for timer_type in list:
		if timer_type.name == name:
			return timer_type.color
	return default_color