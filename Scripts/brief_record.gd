extends Resource
class_name BriefRecord

var total_times: Dictionary = {}
var is_empty: bool = true
var last_activated_type: int = 1
var last_timestamp: int = 0

func to_dict() -> Dictionary:
	return {
		"total_times": total_times,
		"is_empty": is_empty,
		"last_activated_type": last_activated_type,
		"last_timestamp": last_timestamp
	}

static func from_dict(data: Dictionary) -> BriefRecord:
	var record = BriefRecord.new()
	record.total_times = data["total_times"]
	record.is_empty = data["is_empty"]
	record.last_activated_type = data["last_activated_type"]
	record.last_timestamp = data["last_timestamp"]
	return record