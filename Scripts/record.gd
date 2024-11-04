extends Resource
class_name Record

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
	var last_type := 1
	for entry in entries:
		var segment_length := entry.timestamp - last_timestamp
		last_timestamp = entry.timestamp
		if last_type in total_times:
			total_times[last_type] += segment_length
		else:
			total_times[last_type] = segment_length
		last_type = entry.type
	return total_times

func get_brief() -> BriefRecord:
	var brief := BriefRecord.new()
	if is_empty():
		brief.is_empty = true
	else:
		brief.total_times = get_total_times()
		brief.is_empty = false
		brief.last_activated_type = entries.back().type
		brief.last_timestamp = entries.back().timestamp
		return brief
	
	return brief

# 保存和加载

func save_to(path: String) -> int:
	return ResourceSaver.save(self, path, ResourceSaver.SaverFlags.FLAG_COMPRESS)

static func load_from(path: String) -> Record:
	return ResourceLoader.load(path)
