local data           = require("scripts.lib.data")
local const          = require("scripts.lib.const")

local debug          = {}

local debug_instance = nil

function debug.draw_aabb(x, y, width, height, color)
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x + width, y, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x, y + height, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x + width, y, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y + height, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
end

function debug.debug_draw_aabb(aabb_data, color)
	for _, data in ipairs(aabb_data) do
		debug.draw_aabb(data.x, data.y, data.size.width, data.size.height, color)
	end
end

function debug.debug_draw_center_aabb(aabb_data, color)
	for _, data in pairs(aabb_data) do
		local size = { width = data.size.width, height = data.size.height }
		if data.collider_size then
			size = { width = data.collider_size.width, height = data.collider_size.height }
		end

		if data.name == "SLOPE" then
			msg.post("@render:", "draw_line", { start_point = vmath.vector3(data.properties.slope.x1, data.properties.slope.y1, 0), end_point = vmath.vector3(data.properties.slope.x2, data.properties.slope.y2, 0), color = vmath.vector4(0, 1, 1, 1) })
		end

		debug.draw_aabb(data.center.x - (size.width / 2), data.center.y - (size.height / 2), size.width, size.height, color)
	end
end

function toogle_profiler()
	if profiler then
		profiler.enable_ui(data.debug.profiler)
		profiler.set_ui_view_mode(profiler.VIEW_MODE_MINIMIZED)
	end
end

function debug.init()
	if debug_instance == nil then
		debug_instance = factory.create("/factories#debug")
		imgui.set_ini_filename("editor_imgui.ini")
		toogle_profiler()
	end
end

function debug.final()
	go.delete(debug_instance, true)
end

function debug.update()
	if data.debug.colliders then
		debug.debug_draw_center_aabb(data.map_objects, vmath.vector4(1, 0, 0, 1))
		debug.debug_draw_center_aabb(data.props, vmath.vector4(0, 0, 1, 1))
		debug.debug_draw_center_aabb(data.enemies, vmath.vector4(1, 1, 0, 1))
		debug.debug_draw_center_aabb(data.directions, vmath.vector4(1, 1, 0, 1))

		debug.draw_aabb(data.player.position.x - const.PLAYER.HALF_SIZE.w, data.player.position.y - const.PLAYER.HALF_SIZE.h, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h, vmath.vector4(1, 0, 0, 1))

		debug.draw_aabb(data.camera.position.x - (const.CAMERA.DEADZONE.x * 2 / 2), data.camera.position.y - (const.CAMERA.DEADZONE.y * 2 / 2), const.CAMERA.DEADZONE.x * 2, const.CAMERA.DEADZONE.y * 2, vmath.vector4(0, 1, 0, 1))

		debug.draw_aabb(data.player.position.x - const.PLAYER.HALF_SIZE.w, data.player.position.y - const.PLAYER.HALF_SIZE.h - 5, const.PLAYER.SIZE.w, 5, vmath.vector4(1, 1, 1, 1))

		--[[	--back
		local start_point = vmath.vector3(
			data.player.position.x - (const.PLAYER.SIZE.w / 2 - 4),
			data.player.position.y - (const.PLAYER.SIZE.h / 2),
			0)
		local end_point = vmath.vector3(
			data.player.position.x - (const.PLAYER.SIZE.w / 2 - 4),
			data.player.position.y - (const.PLAYER.SIZE.h / 2 + 16),
			0)

		msg.post("@render:", "draw_line", { start_point = start_point, end_point = end_point, color = vmath.vector4(1, 1, 0, 1) })]]


		--center
		local start_point = vmath.vector3(
			data.player.position.x,
			data.player.position.y,
			0)
		local end_point = vmath.vector3(
			data.player.position.x,
			data.player.position.y - (const.PLAYER.HALF_SIZE.h + 16),
			0)

		msg.post("@render:", "draw_line", { start_point = start_point, end_point = end_point, color = vmath.vector4(1, 1, 0, 1) })


		--local ray_start = vmath.vector3(data.player.position.x, data.player.position.y - (const.PLAYER.SIZE.h / 2), 0)
		--local ray_end = vmath.vector3(data.player.position.x, data.player.position.y - (const.PLAYER.SIZE.h / 2 + 5), 0)
		--msg.post("@render:", "draw_line", { start_point = ray_start, end_point = ray_end, color = vmath.vector4(1, 0, 0, 1) })
	end

	if data.debug.imgui then
		----------------------
		-- Imgui
		----------------------
		imgui.begin_window("Properties", nil, imgui.WINDOWFLAGS_MENUBAR)

		imgui.text("GAME STATE")

		if imgui.button("Reset Checkpoints") then
			data.checkpoints     = {}
			data.last_checkpoint = 0
		end


		local changed, checked = imgui.checkbox("pause", data.game.state.pause)
		if changed then
			data.game.state.pause = checked
		end

		local changed, checked = imgui.checkbox("input_pause", data.game.state.input_pause)
		if changed then
			data.game.state.input_pause = checked
		end

		local changed, checked = imgui.checkbox("skip_colliders", data.game.state.skip_colliders)
		if changed then
			data.game.state.skip_colliders = checked
		end


		imgui.separator()
		imgui.text("DEBUG")

		local changed, checked = imgui.checkbox("Colliders", data.debug.colliders)
		if changed then
			data.debug.colliders = checked
		end


		local changed, checked = imgui.checkbox("Imgui", data.debug.imgui)
		if changed then
			data.debug.imgui = checked
		end



		local changed, checked = imgui.checkbox("Profiler", data.debug.profiler)
		if changed then
			data.debug.profiler = checked
			toogle_profiler()
		end

		imgui.separator()
		imgui.text("\nPLAYER")
		imgui.text(("Position = %d %d %d"):format(data.player.position.x, data.player.position.y, data.player.position.z))

		imgui.text(("Velocity = %d %d %d"):format(data.player.velocity.x, data.player.velocity.y, data.player.velocity.z))

		imgui.text(("Gravity Down = %d"):format(data.player.gravity_down))


		imgui.text("\nStates")

		local changed, checked = imgui.checkbox("on_ground", data.player.state.on_ground)
		if changed then
			data.player.state.on_ground = checked
		end

		local changed, checked = imgui.checkbox("jump_pressed", data.player.state.jump_pressed)
		if changed then
			data.player.state.jump_pressed = checked
		end

		local changed, checked = imgui.checkbox("is_jumping", data.player.state.is_jumping)
		if changed then
			data.player.state.is_jumping = checked
		end

		local changed, checked = imgui.checkbox("is_walking", data.player.state.is_walking)
		if changed then
			data.player.state.is_walking = checked
		end

		local changed, checked = imgui.checkbox("is_sliding", data.player.state.is_sliding)
		if changed then
			data.player.state.is_sliding = checked
		end

		local changed, checked = imgui.checkbox("is_falling", data.player.state.is_falling)
		if changed then
			data.player.state.is_sliding = checked
		end

		local changed, checked = imgui.checkbox("on_slope", data.player.state.on_slope)
		if changed then
			data.player.state.on_slope = checked
		end



		-- local changed, checked = imgui.checkbox("is_wall_jump", data.player.state.is_wall_jump)
		-- if changed then
		-- 	data.player.state.is_wall_jump = checked
		-- end
		-- imgui.text(("on_ground: %a"):format(data.player.state.on_ground))
		-- imgui.text(("jump_pressed: %a"):format(data.player.state.jump_pressed))
		-- imgui.text(("is_walking: %a"):format(data.player.state.is_walking))
		-- imgui.text(("is_sliding: %a"):format(data.player.state.is_sliding))
		-- imgui.text(("is_falling: %a"):format(data.player.state.is_falling))
		-- mgui.text(("is_wall_jump: %a"):format(data.player.state.is_wall_jump))

		imgui.text("\nSettings")

		local changed, int = imgui.input_int("MOVE_ACCELERATION", const.PLAYER.MOVE_ACCELERATION)
		if changed then
			const.PLAYER.MOVE_ACCELERATION = int
		end

		changed, int = imgui.input_int("MOVE_ACCELERATION", const.PLAYER.MAX_MOVE_SPEED)
		if changed then
			const.PLAYER.MAX_MOVE_SPEED = int
		end

		local changed, p = imgui.drag_float("DECELERATION_LERP", const.PLAYER.DECELERATION_LERP, 0.01, 0.0, 100.0)
		if changed then
			const.PLAYER.DECELERATION_LERP = p
		end

		changed, int = imgui.input_int("JUMP_FORCE", const.PLAYER.JUMP_FORCE)
		if changed then
			const.PLAYER.JUMP_FORCE = int
		end
		changed, int = imgui.input_int("WALL_JUMP_FORCE", const.PLAYER.WALL_JUMP_FORCE)
		if changed then
			const.PLAYER.WALL_JUMP_FORCE = int
		end

		changed, int = imgui.input_int("TRAMPOLINE_JUMP_FORCE", const.PLAYER.TRAMPOLINE_JUMP_FORCE)
		if changed then
			const.PLAYER.TRAMPOLINE_JUMP_FORCE = int
		end


		changed, int = imgui.input_int("GRAVITY_UP", const.PLAYER.GRAVITY_UP)
		if changed then
			const.PLAYER.GRAVITY_UP = int
		end
		changed, int = imgui.input_int("GRAVITY_DOWN", const.PLAYER.GRAVITY_DOWN)
		if changed then
			const.PLAYER.GRAVITY_DOWN = int
		end
		changed, int = imgui.input_int("GRAVITY_SLIDE", const.PLAYER.GRAVITY_SLIDE)
		if changed then
			const.PLAYER.GRAVITY_SLIDE = int
		end

		changed, int = imgui.input_int("GRAVITY_WALL_JUMP", const.PLAYER.GRAVITY_WALL_JUMP)
		if changed then
			const.PLAYER.GRAVITY_WALL_JUMP = int
		end

		changed, int = imgui.input_float("MAX_JUMP_HOLD_TIME", const.PLAYER.MAX_JUMP_HOLD_TIME)
		if changed then
			const.PLAYER.MAX_JUMP_HOLD_TIME = int
		end

		imgui.separator()
		imgui.text("\nCAMERA")

		imgui.text(("Zoom = %d"):format(go.get(const.URLS.CAMERA_ID, "orthographic_zoom")))
		imgui.text(("Position = %d %d %d"):format(data.camera.position.x, data.camera.position.y, data.camera.position.z))



		local changed, x, y, z = imgui.input_float3("DEADZONE", const.CAMERA.DEADZONE.x, const.CAMERA.DEADZONE.y, const.CAMERA.DEADZONE.z)
		if changed then
			const.CAMERA.DEADZONE.x = x
			const.CAMERA.DEADZONE.y = y
			const.CAMERA.DEADZONE.z = z
		end


		local changed, x, y, z = imgui.input_float3("BOUNDS_MIN", const.CAMERA.BOUNDS_MIN.x, const.CAMERA.BOUNDS_MIN.y, const.CAMERA.BOUNDS_MIN.z)
		if changed then
			const.CAMERA.BOUNDS_MIN.x = x
			const.CAMERA.BOUNDS_MIN.y = y
			const.CAMERA.BOUNDS_MIN.z = z
		end
		imgui.same_line()
		imgui.text("Minimum camera bound position (left/bottom)")

		local changed, x, y, z = imgui.input_float3("BOUNDS_MAX", const.CAMERA.BOUNDS_MAX.x, const.CAMERA.BOUNDS_MAX.y, const.CAMERA.BOUNDS_MAX.z)
		if changed then
			const.CAMERA.BOUNDS_MAX.x = x
			const.CAMERA.BOUNDS_MAX.y = y
			const.CAMERA.BOUNDS_MAX.z = z
		end
		imgui.same_line()
		imgui.text("Maximum camera bound position (right/top)")

		local changed, p = imgui.drag_float("CAMERA_LERP", const.CAMERA.CAMERA_LERP, 0.1, 0.0, 100.0)
		if changed then
			const.CAMERA.CAMERA_LERP = p
		end

		imgui.separator()
		imgui.end_window()
	end
end

return debug
