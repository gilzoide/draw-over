extends Node2D

enum Format {
	LINE_STRIP,
	RECTANGLE,
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
	update()
