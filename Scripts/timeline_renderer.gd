class_name TimelineRenderer

static func render(record: Record, size: Vector2i, step_sec: int):
	var image: Image = Image.create_empty(size.x, size.y, false, Image.FORMAT_RGBA8)
	var record_size: int = record.size()
	var index: int = 0
	var color := Palette.get_color(1)

	image.fill(Color.BLACK)

	# 防止记录是完全空的
	if record_size == 0:
		return image

	for x in range(size.x):
		for y in range(size.y):
			var time: int = step_sec * (x * size.y + y)
			if time >= 86400:
				return image
			
			while time > record.entries[index].timestamp:
				index += 1
				if index == record_size:
					return image
				color = TimerTypeList.get_color(record.entries[index].timer_name)

			image.set_pixel(x, y, color)

	return image