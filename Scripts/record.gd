extends Resource
class_name Record

const format_version: int = 1
@export var entries: Array[Entry]

# 基本操作

func size() -> int:
	return entries.size()

func at(index: int) -> Entry:
	return entries[index]

func push(entry: Entry) -> void:
	entries.push_back(entry)

func pop() -> Entry:
	return entries.pop_back()

func peek() -> Entry:
	return entries.back()

func is_empty() -> bool:
	return entries.size() == 0

# 高级操作
func get_total_times() -> Dictionary:
	var total_times := Dictionary()
	var last_timestamp := 0
	var last_timer_name := TimerTypeList.at(0).timer_name
	for entry in entries:
		var segment_length := entry.timestamp - last_timestamp
		last_timestamp = entry.timestamp
		if last_timer_name in total_times:
			total_times[last_timer_name] += segment_length
		else:
			total_times[last_timer_name] = segment_length
		last_timer_name = entry.timer_name
	return total_times

func get_brief() -> BriefRecord:
	var brief := BriefRecord.new()
	if is_empty():
		brief.is_empty = true
	else:
		brief.total_times = get_total_times()
		brief.is_empty = false
		brief.last_activated_name = entries.back().timer_name
		brief.last_timestamp = entries.back().timestamp
		return brief
	
	return brief

# 保存和加载

func to_dict() -> Dictionary:
	var dict := Dictionary()
	dict["format_version"] = format_version
	dict["entries"] = []
	for entry in entries:
		dict["entries"].push_back(entry.to_dict())
	return dict

static func from_dict(dict: Dictionary) -> Record:
	var record := Record.new()

	if dict["format_version"] != format_version:
		printerr("Error: format version mismatch")
		return record

	for entry_dict in dict["entries"]:
		record.push(Entry.from_dict(entry_dict))
	return record

func to_json() -> String:
	return JSON.stringify(to_dict())

static func from_json(json_string: String) -> Record:
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("Error parsing JSON: %s" % [str(error)])
		return Record.new()
	
	return from_dict(json.data)


func save_to(path: String) -> void:
	var json_string = to_json()
	# var file := FileAccess.open_compressed(path, FileAccess.ModeFlags.WRITE, FileAccess.CompressionMode.COMPRESSION_GZIP)
	var file := FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	file.store_string(json_string)
	file.close()

static func load_from(path: String) -> Record:
	# var file := FileAccess.open_compressed(path, FileAccess.ModeFlags.READ, FileAccess.CompressionMode.COMPRESSION_GZIP)
	var file := FileAccess.open(path, FileAccess.ModeFlags.READ_WRITE)
	var json_string = file.get_as_text()
	file.close()
	return from_json(json_string)
