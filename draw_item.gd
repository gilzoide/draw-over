extends Node2D

enum Format {
	LINE_STRIP,
	RECTANGLE,
	ELLIPSE,
}

export(Format) var format = Format.LINE_STRIP

export(Color) var color = Color.white
var origin: Vector2
var param  # PoolVector2Array for LINE_STRIP, Rect2 for others


func _draw() -> void:
	if format == Format.LINE_STRIP:
		draw_polyline(param, color)
	elif format == Format.RECTANGLE:
		draw_rect(param, color, false)
	elif format == Format.ELLIPSE:
		var size = param.size
		var center = param.position + size * 0.5
		draw_set_transform(center, 0, size)
		draw_arc(Vector2.ZERO, 0.5, 0, TAU, int(clamp(max(size.x, size.y), 3, 64)), color)


func start(point: Vector2) -> void:
	origin = point
	if format == Format.LINE_STRIP:
		param = PoolVector2Array([point, point + Vector2(1, 0)])
	else:
		param = Rect2(point, Vector2.ONE)
	update()


func update_point(point: Vector2) -> void:
	if format == Format.LINE_STRIP:
		param.append(point)
	else:
		param = Rect2(origin, Vector2.ONE).expand(point)
		if param.size.x < 1:
			param.size.x = 1
		if param.size.y < 1:
			param.size.y = 1
	update()
