extends Resource
class_name BriefRecord

var total_times: Dictionary
var is_empty: bool
var last_activated_name: String
var last_timestamp: int

func to_dict() -> Dictionary:
	return {
		"total_times": total_times,
		"is_empty": is_empty,
		"last_activated_name": last_activated_name,
		"last_timestamp": last_timestamp
	}

static func from_dict(data: Dictionary) -> BriefRecord:
	var record = BriefRecord.new()
	record.total_times = data["total_times"]
	record.is_empty = data["is_empty"]
	record.last_activated_name = data["last_activated_name"]
	record.last_timestamp = data["last_timestamp"]
	return record