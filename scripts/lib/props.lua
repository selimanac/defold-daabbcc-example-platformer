local const        = require("scripts.lib.const")
local utils        = require("scripts.lib.utils")
local data         = require("scripts.lib.data")
local collision    = require("scripts.lib.collision")
local player_state = require("scripts.lib.player_state")

local props        = {}

local function init_falling_platform(prop, query_result, callback_fnc)
	if query_result.normal_y == 1 and prop.status == false then
		prop.status = true
		sprite.play_flipbook(prop.sprite, prop.anims.on)

		timer.delay(0.5, false, function()
			collision.remove(prop.aabb_id)
			go.animate(prop.sprite, "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 0.2, 0)

			go.animate(prop.id, "position.y", go.PLAYBACK_ONCE_FORWARD, prop.position.y - 30, go.EASING_LINEAR, 0.2, 0, function()
				go.delete(prop.id)
				data.props[prop.aabb_id] = nil
			end)
		end)
	end
end


local function init_trampoline(prop, query_result)
	if query_result.normal_y == 1 and prop.status == false then
		prop.status = true
		sprite.play_flipbook(prop.sprite, prop.anims.on)
		player_state.jump(0)
		data.player.velocity.y = data.player.velocity.y - (const.PLAYER.GRAVITY_UP * 0.5)
		prop.status = false
	end
end

props.TYPE = {
	FALLING_PLATFORM = {
		size = { width = 32, height = 10 },
		collider_size = { width = 32, height = 10 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_falling_platform,
		factory = const.FACTORIES.FALLING_PLATFORM,
		position = vmath.vector3(),
		status = false,
		aabb_id = 0,
		id = nil,
		sprite = nil,
		anims = {
			idle = hash("falling_platform_idle"),
			on = hash("falling_platform_on"),
		}
	},
	TRAMPOLINE = {
		size = { width = 27, height = 27 },
		collider_size = { width = 23, height = 11 },
		offset = vmath.vector3(0, 8, 0),
		center = { x = 0, y = 0 },
		fn = init_trampoline,
		factory = const.FACTORIES.TRAMPOLINE,
		position = vmath.vector3(),
		status = false,
		aabb_id = 0,
		id = nil,
		sprite = nil,
		anims = {
			idle = hash("trampoline_idle"),
			on = hash("trampoline_on"),
		}
	}

}


function props.add(x, y, width, height, type)
	local prop = utils.table_copy(props.TYPE[type])

	prop.center.x = x + (prop.size.width / 2)
	prop.center.y = (data.map_height - y) + (prop.size.height / 2)
	prop.position = vmath.vector3(prop.center.x, prop.center.y, 0.1)

	prop.id = factory.create(prop.factory, prop.position)
	prop.sprite = msg.url(prop.id)
	prop.sprite.fragment = "sprite"

	prop.center.x = prop.center.x - prop.offset.x
	prop.center.y = prop.center.y - prop.offset.y
	prop.aabb_id = collision.insert_aabb(prop.center.x, prop.center.y, prop.collider_size.width, prop.collider_size.height, const.COLLISION_BITS.TILE)

	data.props[prop.aabb_id] = prop
end

return props
