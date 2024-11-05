class_name Consts

const default_folder: String = "user://records"
const folder_env_name: String = "TIMER_RECORDS_FOLDER"

static func get_records_folder() -> String:
	if OS.has_environment(folder_env_name):
		return OS.get_environment(folder_env_name)
	else:
		return default_folder

static func get_records_file_path(file_name: String) -> String:
	return get_records_folder() + "/" + file_name