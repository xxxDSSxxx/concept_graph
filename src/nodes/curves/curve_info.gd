"""
Returns the maximum width, length and height of the curve and the center position averaged from
each points
"""

tool
class_name ConceptNodeCurveInfo
extends ConceptNode


var _resolution := 0.2 # TMP
var _size: Vector3
var _center: Vector3
var _calculated = false


func _init() -> void:
	set_input(0, "Curve", ConceptGraphDataType.CURVE)
	set_output(0, "Size", ConceptGraphDataType.VECTOR)
	set_output(1, "Center", ConceptGraphDataType.VECTOR)


func get_node_name() -> String:
	return "Curve Info"


func get_description() -> String:
	return "Exposes the BoundingBox and the Center position of a curve"


func get_category() -> String:
	return "Curves"


func get_output(idx: int) -> Vector3:
	var curve = get_input(0)
	if not curve:
		return Vector3.ZERO
	if not _calculated:
		_calculate_info(curve)
	match idx:
		0:
			return _size
		1:
			return _center

	return Vector3.ZERO


func _calculate_info(curve: Curve3D) -> void:
	var _min: Vector3
	var _max: Vector3

	var length = curve.get_baked_length()
	var steps = round(length / _resolution)

	if steps == 0:
		return

	for i in range(steps):
		# Get a point on the curve
		var coords = curve.interpolate_baked((i/(steps-2)) * length)

		# Check for bounds
		if i == 0:
			_min = coords
			_max = coords
		else:
			if coords.x > _max.x:
				_max.x = coords.x
			if coords.x < _min.x:
				_min.x = coords.x
			if coords.y > _max.y:
				_max.y = coords.y
			if coords.y < _min.y:
				_min.y = coords.y
			if coords.z > _max.z:
				_max.z = coords.z
			if coords.z < _min.z:
				_min.z = coords.z

	_size = Vector3(_max.x - _min.x, _max.y - _min.y, _max.z - _min.z)
	_center = Vector3((_min.x + _max.x) / 2, (_min.y + _max.y) / 2, (_min.z + _max.z) / 2)


func _clear_cache() -> void:
	_calculated = false