extends Resource
class_name TimerType

@export var timer_name: String = "Name"
@export var color: Color = Color.SKY_BLUE

static func create(timer_name: String, color: Color) -> TimerType:
	var timerType := TimerType.new()
	timerType.timer_name = timer_name
	timerType.color = color
	return timerType