extends Label
class_name ResponsiveLabel

@export var label_size_ratio: float = 0.8

@onready var original_size := size
@onready var original_font_size := label_settings.font_size
@onready var original_outline_size := label_settings.outline_size

func update_font_size(container_size: Vector2) -> void:
	var factors: Vector2 = container_size / original_size
	var scale = label_size_ratio * min(factors.x, factors.y)
	label_settings.font_size = original_font_size * scale
	label_settings.outline_size = original_outline_size * scale