class_name Palette

static var colors: Array[Color] = [
	Color("#ff77a8"),
	Color("#ffec27"),
	Color("#66dd3a"),
	Color("#297bff"),
	Color("#bb29ff"),
	Color("#ffa300"),
	Color("#4dffea"),
	Color("#ff004d"),
	# Color("#0fb672"),
]

static func get_color(index: int) -> Color:
	return colors[(index - 1) % colors.size()]
