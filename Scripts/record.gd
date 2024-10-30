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

# 保存和加载

func save_to(path: String) -> int:
	return ResourceSaver.save(self, path)

static func load_from(path: String) -> Record:
	return ResourceLoader.load(path)
