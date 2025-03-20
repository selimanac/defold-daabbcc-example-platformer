local data        = require("scripts.lib.data")
local const       = require("scripts.lib.const")

local game_camera = {}

local new_cam_pos = vmath.vector3()
local is_init     = false


local function get_target_camera_pos(cam_pos, player_pos, deadzone)
	local offset = player_pos - cam_pos
	local target_offset = vmath.vector3(0, 0, 0)

	-- Horizontal deadzone check
	if offset.x > deadzone.x then
		target_offset.x = offset.x - deadzone.x
	elseif offset.x < -deadzone.x then
		target_offset.x = offset.x + deadzone.x
	end

	-- Vertical deadzone check
	if offset.y > deadzone.y then
		target_offset.y = offset.y - deadzone.y
	elseif player_pos.y < cam_pos.y then
		-- Follow the player when falling (ignoring deadzone)
		target_offset.y = offset.y + 32
	end

	return cam_pos + target_offset
end

function game_camera.update(dt)
	data.camera.deadzone = get_target_camera_pos(data.camera.position, data.player.position, const.CAMERA.DEADZONE)
	new_cam_pos = vmath.lerp(const.CAMERA.CAMERA_LERP * dt, data.camera.position, data.camera.deadzone)

	-- Clamp
	new_cam_pos.x = math.max(const.CAMERA.BOUNDS_MIN.x, math.min(const.CAMERA.BOUNDS_MAX.x, new_cam_pos.x))
	new_cam_pos.y = math.max(const.CAMERA.BOUNDS_MIN.y, math.min(const.CAMERA.BOUNDS_MAX.y, new_cam_pos.y))

	go.set_position(new_cam_pos, const.URLS.CAMERA_CONTAINER)
	data.camera.position = new_cam_pos
	data.camera.base_position = new_cam_pos
end

function game_camera.set_zoom(size)
	--  Might require scale factor : https://github.com/britzl/defold-orthographic?tab=readme-ov-file#cameraset_window_scaling_factorscaling_factor
	local new_camera_zoom = math.floor(math.max(size.width / const.DISPLAY_WIDTH, size.height / const.DISPLAY_HEIGHT) * data.camera.zoom)

	go.set(const.URLS.CAMERA_ID, "orthographic_zoom", new_camera_zoom)
end

local function window_event(self, event, size)
	if event == window.WINDOW_EVENT_FOCUS_LOST then
		data.set_game_pause(true)
	elseif event == window.WINDOW_EVENT_ICONFIED then
		data.set_game_pause(true)
	elseif event == window.WINDOW_EVENT_RESIZED then
		data.set_game_pause(true)
		game_camera.set_zoom(size)
		data.window_size = size
		msg.post(const.URLS.GUI, const.MSG.UPDATE_SIZE)
	end
end

function game_camera.init()
	data.camera.position = data.player.position

	go.set_position(data.camera.position, const.URLS.CAMERA_CONTAINER)

	if is_init == false then
		data.camera.zoom = go.get(const.URLS.CAMERA_ID, "orthographic_zoom")

		local x, y, w, h = defos.get_view_size()

		data.window_size.width = w
		data.window_size.height = h
		game_camera.set_zoom(data.window_size)
		window.set_listener(window_event)
	end

	is_init = true
end

return game_camera
