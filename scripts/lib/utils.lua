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

function utils.merge_tables(t1, t2)
	-- If one of them is nil, return the other
	if not t1 then return t2 or {} end
	if not t2 then return t1 end

	local result = {}

	-- Copy t1
	for i, v in ipairs(t1) do
		result[i] = v
	end

	-- Overwrite with values from t2
	for i, v in ipairs(t2) do
		result[i] = v
	end

	return result
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
	if object_data.rotation == 0 then
		return nil
	else
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

		return vmath.quat_rotation_z(math.rad(object_data.rotation * -1))
	end
end

function utils.set_object_properties(object_properties)
	if object_properties then
		local properties = {}
		for _, property in ipairs(object_properties) do
			properties[property.name] = property.value
		end
		return properties
	end

	return {}
end

function utils.flip_object_sprite(object_sprite, hflip, vflip)
	sprite.set_hflip(object_sprite, hflip == true or hflip == 1)
	sprite.set_vflip(object_sprite, vflip == true or vflip == 1)
end

function utils.rotate_object_collider(rotation, object)
	if rotation then
		local rotated_size = vmath.rotate(rotation, vmath.vector3(object.collider_size.width, object.collider_size.height, 0))
		object.offset = vmath.rotate(rotation, object.offset)
		object.collider_size.width = math.abs(rotated_size.x)
		object.collider_size.height = math.abs(rotated_size.y)
	end
end

return utils
