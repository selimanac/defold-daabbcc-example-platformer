local data                 = require("scripts.lib.data")
local const                = require("scripts.lib.const")

local game_camera          = {}

local next_camera_position = vmath.vector3()
local is_init              = false
local camera_target_offset = vmath.vector3(0, 0, 0)
local camera_offset        = vmath.vector3()

local function get_target_camera_pos(camera_position, player_position, deadzone)
	camera_offset.x = player_position.x - camera_position.x
	camera_offset.y = player_position.y - camera_position.y

	camera_target_offset.x = 0
	camera_target_offset.y = 0

	-- Horizontal deadzone check
	if camera_offset.x > deadzone.x then
		camera_target_offset.x = camera_offset.x - deadzone.x
	elseif camera_offset.x < -deadzone.x then
		camera_target_offset.x = camera_offset.x + deadzone.x
	end

	-- Vertical deadzone check
	if camera_offset.y > deadzone.y then
		camera_target_offset.y = camera_offset.y - deadzone.y
	elseif player_position.y < camera_position.y then
		-- Follow the player when falling (ignoring deadzone)
		camera_target_offset.y = camera_offset.y + 32
	end

	return camera_position + camera_target_offset
end

function game_camera.update(dt)
	data.camera.deadzone = get_target_camera_pos(data.camera.position, data.player.position, const.CAMERA.DEADZONE)
	next_camera_position = vmath.lerp(const.CAMERA.CAMERA_LERP * dt, data.camera.position, data.camera.deadzone)

	-- Clamp
	next_camera_position.x = math.max(const.CAMERA.BOUNDS_MIN.x, math.min(const.CAMERA.BOUNDS_MAX.x, next_camera_position.x))
	next_camera_position.y = math.max(const.CAMERA.BOUNDS_MIN.y, math.min(const.CAMERA.BOUNDS_MAX.y, next_camera_position.y))

	go.set_position(next_camera_position, const.URLS.CAMERA_CONTAINER)
	data.camera.position = next_camera_position
	data.camera.base_position = next_camera_position
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

		local _, _, w, h = defos.get_view_size()

		data.window_size.width = w
		data.window_size.height = h

		game_camera.set_zoom(data.window_size)
		window.set_listener(window_event)
	end

	is_init = true
end

return game_camera
