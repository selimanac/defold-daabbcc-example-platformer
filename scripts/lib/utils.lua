local utils = {}

function utils.table_copy(tbl)
	local copy = {}
	for key, value in pairs(tbl) do
		if type(value) ~= 'table' then
			copy[key] = value
		else
			copy[key] = utils.table_copy(value)
		end
	end
	return copy
end

function utils.slope_intercept(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	local m = dy / dx
	local b = y1 - m * x1
	return m, b
end

-- object rotation is very problematic at Tiled. this is a very ugly solution
function utils.object_rotate(object_data)
	local size = vmath.vector3(object_data.width, object_data.height, 0)
	local rotated_size = vmath.rotate(vmath.quat_rotation_z(math.rad(object_data.rotation * -1)), size)

	rotated_size.x = math.abs(rotated_size.x)
	rotated_size.y = math.abs(rotated_size.y)

	local centerX = object_data.width / 2
	local centerY = object_data.height / 2
	local cosRotation = math.cos(math.rad(object_data.rotation))
	local sinRotation = math.sin(math.rad(object_data.rotation))
	local rotatedCenterX = centerX * cosRotation - centerY * sinRotation
	local rotatedCenterY = centerX * sinRotation + centerY * cosRotation

	if object_data.rotation == -90 or object_data.rotation == 90 then
		object_data.x = math.floor(object_data.x - rotatedCenterX - (object_data.width / 2))
		object_data.y = math.floor((object_data.y + rotatedCenterY) + (object_data.height / 2))
	elseif object_data.rotation == 180 or object_data.rotation == -180 then
		object_data.x = math.floor(object_data.x - rotatedCenterX - (object_data.width + (object_data.width / 2)))
		object_data.y = math.floor((object_data.y + rotatedCenterY) + (object_data.height + object_data.height / 2))
	end

	object_data.width  = rotated_size.x
	object_data.height = rotated_size.y
end

return utils
