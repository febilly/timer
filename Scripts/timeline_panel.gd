extends Control
class_name TimelinePanel

@export var max_width: int = 600

@onready var texture_rect: TextureRect = %TimelineBar
@onready var date_label: ResponsiveLabel = %DateLabel
@onready var timeline_panel_aspect: AspectRatioContainer = %TimelinePanelAspect

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var width = min(max_width, size.x)
	custom_minimum_size.y = width / timeline_panel_aspect.ratio
	date_label.update_font_size(size)

func load_timeline(filepath: String, date: String) -> bool:
	if not FileAccess.file_exists(filepath):
		return false

	var record = Record.load_from(filepath)
	# print(record)
	if record is not Record:
		return false

	date_label.text = date

	var timeline_image = TimelineRenderer.render(record, Vector2i(320, 27), 10)
	# print(timeline_image)
	# print(timeline_image.get_size())
	var timeline_texutre = ImageTexture.create_from_image(timeline_image)
	texture_rect.texture = timeline_texutre

	return true