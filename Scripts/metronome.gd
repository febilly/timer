extends Node

signal tick(seconds: int)

var last_seconds := get_seconds_of_the_day()

func get_seconds_of_the_day() -> int:
    var time_dict := Time.get_time_dict_from_system()
    return time_dict["hour"] * 3600 + time_dict["minute"] * 60 + time_dict["second"]

func _process(delta: float) -> void:
    var now_seconds = get_seconds_of_the_day()
    if now_seconds != last_seconds:
        last_seconds = now_seconds
        tick.emit(now_seconds)