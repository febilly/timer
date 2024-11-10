class_name Globals

const default_folder: String = "user://"
const folder_env_name: String = "TIMER_DATA_FOLDER"

static func get_data_folder() -> String:
	if OS.has_environment(folder_env_name):
		return OS.get_environment(folder_env_name)
	else:
		return default_folder

static func get_records_folder() -> String:
	var parent_folder = get_data_folder()
	if not parent_folder.ends_with("/"):
		parent_folder += "/"
	return parent_folder + "records"


static func get_data_file_path(file_name: String) -> String:
	var parent_folder = get_data_folder()
	if not parent_folder.ends_with("/"):
		parent_folder += "/"
	return parent_folder + file_name

static func get_records_file_path(file_name: String) -> String:
	var parent_folder = get_records_folder()
	if not parent_folder.ends_with("/"):
		parent_folder += "/"
	return parent_folder + file_name


static func is_run_in_server_mode():
	return "--server" in OS.get_cmdline_args() or OS.has_feature("dedicated_server")
	# return OS.has_feature("editor") or "--server" in OS.get_cmdline_args()
	# return true

static func is_debugging_time_offset():
	return OS.has_environment("DEBUG_TIME_OFFSET") or "--debug_time_offset" in OS.get_cmdline_args()