extends Resource
class_name Entry

@export var timer_name: String
@export var timestamp: int

func to_dict() -> Dictionary:
	return {
		"timer_name": timer_name,
		"timestamp": timestamp
	}

static func from_dict(data: Dictionary):
	var entry = Entry.new()
	entry.timer_name = data["timer_name"]
	entry.timestamp = data["timestamp"]
	return entry
