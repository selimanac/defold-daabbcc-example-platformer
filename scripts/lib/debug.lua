local data            = require("scripts.lib.data")
local const           = require("scripts.lib.const")
local checkpoints     = require("scripts.game.props.checkpoint")

local debug           = {}

local debug_instance  = nil
local ray_start_point = vmath.vector3()
local ray_end_point   = vmath.vector3()
local changed         = false
local checked         = false
local int             = 0
local float           = 0.0
local x               = 0.0
local y               = 0.0
local z               = 0.0
local colors          = {
	RED    = vmath.vector4(1, 0, 0, 1),
	BLUE   = vmath.vector4(0, 0, 1, 1),
	YELLOW = vmath.vector4(1, 1, 0, 1),
	GREEN  = vmath.vector4(0, 1, 0, 1)
}

local function draw_aabb(x, y, width, height, color)
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x + width, y, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y, 0), end_point = vmath.vector3(x, y + height, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x + width, y, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
	msg.post("@render:", "draw_line", { start_point = vmath.vector3(x, y + height, 0), end_point = vmath.vector3(x + width, y + height, 0), color = color })
end

local function debug_draw_aabb(aabb_data, color)
	for _, item in ipairs(aabb_data) do
		draw_aabb(item.x, item.y, item.size.width, item.size.height, color)
	end
end

local function debug_draw_center_aabb(aabb_data, color)
	for _, item in pairs(aabb_data) do
		local size = { width = item.size.width, height = item.size.height }
		if item.collider_size then
			size = { width = item.collider_size.width, height = item.collider_size.height }
		end

		if item.name == "SLOPE" then
			msg.post("@render:", "draw_line", { start_point = vmath.vector3(item.properties.slope.x1, item.properties.slope.y1, 0), end_point = vmath.vector3(item.properties.slope.x2, item.properties.slope.y2, 0), color = colors.RED })
		end

		draw_aabb(item.center.x - (size.width / 2), item.center.y - (size.height / 2), size.width, size.height, color)
	end
end

local function toogle_profiler()
	if profiler then
		profiler.enable_ui(data.debug.profiler)
		profiler.set_ui_view_mode(profiler.VIEW_MODE_MINIMIZED)
	end
end

function debug.init()
	if debug_instance == nil then
		factory.unload("/factories#debug")
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
		debug_draw_center_aabb(data.map_objects, colors.RED)
		debug_draw_center_aabb(data.props, colors.BLUE)
		debug_draw_center_aabb(data.enemies, colors.YELLOW)
		debug_draw_center_aabb(data.directions, colors.YELLOW)

		-- player
		draw_aabb(data.player.position.x - const.PLAYER.HALF_SIZE.w, data.player.position.y - const.PLAYER.HALF_SIZE.h, const.PLAYER.SIZE.w, const.PLAYER.SIZE.h, colors.RED)

		-- camera deadzone
		draw_aabb(data.camera.position.x - (const.CAMERA.DEADZONE.x * 2 / 2), data.camera.position.y - (const.CAMERA.DEADZONE.y * 2 / 2), const.CAMERA.DEADZONE.x * 2, const.CAMERA.DEADZONE.y * 2, colors.GREEN)

		--------------------------
		-- Player Rays
		--------------------------

		--Slope
		ray_start_point.x = data.player.position.x
		ray_start_point.y = data.player.position.y

		ray_end_point.x = data.player.position.x
		ray_end_point.y = data.player.position.y - const.PLAYER.RAY_Y

		msg.post("@render:", "draw_line", { start_point = ray_start_point, end_point = ray_end_point, color = colors.YELLOW })

		--Back ray for platforms
		ray_start_point.x = data.player.position.x
		ray_start_point.y = data.player.position.y

		ray_end_point.x = data.player.position.x - const.PLAYER.HALF_SIZE.w
		ray_end_point.y = data.player.position.y - const.PLAYER.RAY_Y

		msg.post("@render:", "draw_line", { start_point = ray_start_point, end_point = ray_end_point, color = colors.RED })


		--Front ray for platforms
		ray_start_point.x = data.player.position.x
		ray_start_point.y = data.player.position.y

		ray_end_point.x = data.player.position.x + const.PLAYER.HALF_SIZE.w
		ray_end_point.y = data.player.position.y - const.PLAYER.RAY_Y

		msg.post("@render:", "draw_line", { start_point = ray_start_point, end_point = ray_end_point, color = colors.RED })
	end

	----------------------
	-- Imgui
	----------------------

	if data.debug.imgui then
		imgui.begin_window("Properties", nil, imgui.WINDOWFLAGS_MENUBAR)

		imgui.text("GAME STATE")

		if imgui.button("Reset Checkpoints") then
			checkpoints.reset()
		end

		changed, checked = imgui.checkbox("pause", data.game.state.pause)
		if changed then
			data.set_game_pause(checked)
		end

		imgui.checkbox("input_pause", data.game.state.input_pause)
		imgui.checkbox("skip_colliders", data.game.state.skip_colliders)

		---------------------------------------------------
		imgui.separator()
		---------------------------------------------------

		imgui.text("DEBUG")

		changed, checked = imgui.checkbox("Colliders", data.debug.colliders)
		if changed then
			data.debug.colliders = checked
		end

		changed, checked = imgui.checkbox("Imgui", data.debug.imgui)
		if changed then
			data.debug.imgui = checked
		end

		changed, checked = imgui.checkbox("Profiler", data.debug.profiler)
		if changed then
			data.debug.profiler = checked
			toogle_profiler()
		end

		---------------------------------------------------
		imgui.separator()
		---------------------------------------------------

		imgui.text("\nPLAYER")

		imgui.text(("Position = %d %d %d"):format(data.player.position.x, data.player.position.y, data.player.position.z))

		imgui.text(("Velocity = %d %d %d"):format(data.player.velocity.x, data.player.velocity.y, data.player.velocity.z))

		imgui.text(("Gravity Down = %d"):format(data.player.gravity_down))

		imgui.text(("Health = %d"):format(data.player.health))

		imgui.text(("Apples = %d"):format(data.player.collected_apples))

		imgui.text("\nStates")

		changed, checked = imgui.checkbox("on_ground", data.player.state.on_ground)
		if changed then
			data.player.state.on_ground = checked
		end

		changed, checked = imgui.checkbox("jump_pressed", data.player.state.jump_pressed)
		if changed then
			data.player.state.jump_pressed = checked
		end

		changed, checked = imgui.checkbox("is_jumping", data.player.state.is_jumping)
		if changed then
			data.player.state.is_jumping = checked
		end

		changed, checked = imgui.checkbox("is_walking", data.player.state.is_walking)
		if changed then
			data.player.state.is_walking = checked
		end

		changed, checked = imgui.checkbox("is_sliding", data.player.state.is_sliding)
		if changed then
			data.player.state.is_sliding = checked
		end

		changed, checked = imgui.checkbox("is_falling", data.player.state.is_falling)
		if changed then
			data.player.state.is_sliding = checked
		end

		changed, checked = imgui.checkbox("on_slope", data.player.state.on_slope)
		if changed then
			data.player.state.on_slope = checked
		end

		changed, checked = imgui.checkbox("over_platform", data.player.state.over_platform)
		if changed then
			data.player.state.over_platform = checked
		end

		changed, checked = imgui.checkbox("on_moving_platform", data.player.state.on_moving_platform)
		if changed then
			data.player.state.on_moving_platform = checked
		end

		---------------------------------------------------
		imgui.separator()
		---------------------------------------------------

		imgui.text("\nSettings")

		changed, int = imgui.input_int("MOVE_ACCELERATION", const.PLAYER.MOVE_ACCELERATION)
		if changed then
			const.PLAYER.MOVE_ACCELERATION = int
		end

		changed, int = imgui.input_int("MOVE_ACCELERATION", const.PLAYER.MAX_MOVE_SPEED)
		if changed then
			const.PLAYER.MAX_MOVE_SPEED = int
		end

		changed, float = imgui.drag_float("DECELERATION_LERP", const.PLAYER.DECELERATION_LERP, 0.01, 0.0, 100.0)
		if changed then
			const.PLAYER.DECELERATION_LERP = float
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

		---------------------------------------------------
		imgui.separator()
		---------------------------------------------------

		imgui.text("\nCAMERA")

		imgui.text(("Zoom = %d"):format(go.get(const.URLS.CAMERA_ID, "orthographic_zoom")))
		imgui.text(("Position = %d %d %d"):format(data.camera.position.x, data.camera.position.y, data.camera.position.z))

		changed, x, y, z = imgui.input_float3("DEADZONE", const.CAMERA.DEADZONE.x, const.CAMERA.DEADZONE.y, const.CAMERA.DEADZONE.z)
		if changed then
			const.CAMERA.DEADZONE.x = x
			const.CAMERA.DEADZONE.y = y
			const.CAMERA.DEADZONE.z = z
		end

		changed, x, y, z = imgui.input_float3("BOUNDS_MIN", const.CAMERA.BOUNDS_MIN.x, const.CAMERA.BOUNDS_MIN.y, const.CAMERA.BOUNDS_MIN.z)
		if changed then
			const.CAMERA.BOUNDS_MIN.x = x
			const.CAMERA.BOUNDS_MIN.y = y
			const.CAMERA.BOUNDS_MIN.z = z
		end
		imgui.same_line()
		imgui.text("Minimum camera bound position (left/bottom)")

		changed, x, y, z = imgui.input_float3("BOUNDS_MAX", const.CAMERA.BOUNDS_MAX.x, const.CAMERA.BOUNDS_MAX.y, const.CAMERA.BOUNDS_MAX.z)
		if changed then
			const.CAMERA.BOUNDS_MAX.x = x
			const.CAMERA.BOUNDS_MAX.y = y
			const.CAMERA.BOUNDS_MAX.z = z
		end
		imgui.same_line()
		imgui.text("Maximum camera bound position (right/top)")

		local changed, float = imgui.drag_float("CAMERA_LERP", const.CAMERA.CAMERA_LERP, 0.1, 0.0, 100.0)
		if changed then
			const.CAMERA.CAMERA_LERP = float
		end

		imgui.end_window()
	end
end

return debug
