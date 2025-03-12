local const        = require("scripts.lib.const")
local data         = require("scripts.lib.data")
local collision    = require("scripts.lib.collision")
local player_state = require("scripts.lib.player_state")
local utils        = require("scripts.lib.utils")

local enemies      = {}

local query_result = {}
local enemy_direction

local function init_enemy(enemy, query_result)
	if query_result.normal_y == 1 and enemy.status == false then
		print("init_enemy")
		enemy.status = true
		enemy.state.is_moving = false

		data.player.state.on_ground = false
		data.player.velocity.y = const.PLAYER.WALL_JUMP_FORCE
		player_state.jump(0)


		collision.remove(enemy.aabb_id)
		sprite.play_flipbook(enemy.sprite, enemy.anims.hit, function()
			go.delete(enemy.id)
		end)

		data.enemies[enemy.aabb_id] = nil
	elseif enemy.status == false and enemy.is_killer then
		player_state.die()
	end
end

local function init_rock_head(enemy, query_result)
	if (query_result.normal_y == 1 or query_result.normal_y == -1) and enemy.status == false then
		enemy.status = true
		player_state.die()
	end
end

enemies.TYPE = {
	ANGRY_PIG = {
		size = { width = 36, height = 30 },
		name = "",
		speed = 0,
		collider_size = { width = 25, height = 23 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_enemy,
		factory = const.FACTORIES.ANGRY_PIG,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		id = nil,
		sprite = nil,
		state = {
			is_moving = false,
			is_idle = false
		},
		is_fixed = false,
		is_killer = true,
		is_flip = true,
		direction_x = 0,
		direction_y = 0,
		collision_bit = const.COLLISION_BITS.ENEMY,
		anims = {
			idle = hash("enemy_angry_pig_idle"),
			walk = hash("enemy_angry_pig_walk"),
			hit = hash("enemy_angry_pig_hit"),
		}
	},
	ROCK_HEAD = {
		size = { width = 32, height = 32 },
		name = "",
		speed = 0,
		collider_size = { width = 32, height = 32 },
		offset = vmath.vector3(),
		center = { x = 0, y = 0 },
		fn = init_rock_head,
		factory = const.FACTORIES.ROCK_HEAD,
		position = vmath.vector3(),
		status = false,
		collectable = false,
		aabb_id = 0,
		id = nil,
		sprite = nil,
		state = {
			is_moving = false,
			is_idle = false
		},
		is_fixed = false,
		is_killer = true,
		is_flip = false,
		direction_x = 0,
		direction_y = 0,
		collision_bit = const.COLLISION_BITS.ENEMY,
		anims = {
			idle = hash("rock_head_idle"),
			top_hit = hash("rock_head_top_hit"),
			bottom_hit = hash("rock_head_bottom_hit"),
		}
	}

}

function enemies.add(object_data, hflip, vflip, properties)
	hflip = hflip and hflip or false
	vflip = vflip and vflip or false

	if object_data.rotation ~= 0 then
		utils.object_rotate(object_data)
	end

	local rotation = object_data.rotation and vmath.quat_rotation_z(math.rad(object_data.rotation * -1)) or nil
	local enemy = utils.table_copy(enemies.TYPE[object_data.name])
	enemy.name = object_data.name
	enemy.center.x = object_data.x + (enemy.size.width / 2)
	enemy.center.y = (data.map_height - object_data.y) + (enemy.size.height / 2)
	enemy.position = vmath.vector3(enemy.center.x, enemy.center.y, 0.1)
	enemy.id = factory.create(enemy.factory, enemy.position, rotation)
	enemy.sprite = msg.url(enemy.id)
	enemy.sprite.fragment = "sprite"


	if properties then
		enemy.direction_x = properties.direction_x
		enemy.direction_y = properties.direction_y
		enemy.speed = properties.speed
	end

	-- h-v flip
	if hflip then
		sprite.set_hflip(enemy.sprite, hflip)
	elseif vflip then
		sprite.set_vflip(enemy.sprite, vflip)
	end

	-- rotate collider
	if rotation then
		local rotated_size = vmath.rotate(rotation, vmath.vector3(enemy.collider_size.width, enemy.collider_size.height, 0))
		enemy.offset = vmath.rotate(rotation, enemy.offset)
		enemy.collider_size.width = math.abs(rotated_size.x)
		enemy.collider_size.height = math.abs(rotated_size.y)
	end

	-- apply offset
	enemy.center.x = enemy.center.x - enemy.offset.x
	enemy.center.y = enemy.center.y - enemy.offset.y

	if not enemy.is_fixed then
		enemy.aabb_id = collision.insert_gameobject(enemy.id, enemy.collider_size.width, enemy.collider_size.height, enemy.collision_bit)
	else
		enemy.aabb_id = collision.insert_aabb(enemy.center.x, enemy.center.y, enemy.collider_size.width, enemy.collider_size.height, enemy.collision_bit)
	end
	print("enemy.aabb_id", enemy.aabb_id)
	enemy.state.is_idle = true

	data.enemies[enemy.aabb_id] = enemy
end

function enemies.update(dt)
	for _, enemy in pairs(data.enemies) do
		if not enemy.is_fixed and enemy.status == false then
			if not enemy.state.is_moving then
				enemy.state.is_moving = true
				enemy.state.is_idle = false
				if enemy.anims.walk then
					sprite.play_flipbook(enemy.sprite, enemy.anims.walk)
				end
			end

			enemy.position.x = enemy.position.x + (enemy.speed * enemy.direction_x) * dt
			enemy.position.y = enemy.position.y + (enemy.speed * enemy.direction_y) * dt
			enemy.center = enemy.position

			collision.update_aabb(enemy.aabb_id, enemy.position.x, enemy.position.y, enemy.collider_size.width, enemy.collider_size.height)

			query_result, _ = collision.query_id(enemy.aabb_id, const.COLLISION_BITS.DIRECTIONS)
			if query_result then
				enemy_direction = data.directions[query_result[1]]
				enemy.direction_x = enemy_direction.direction_x
				enemy.direction_y = enemy_direction.direction_y
				if enemy.is_flip then
					sprite.set_hflip(enemy.sprite, enemy.direction_x == 1 and true or false)
					sprite.set_vflip(enemy.sprite, enemy.direction_y == 1 and true or false)
				end
			end

			go.set_position(enemy.position, enemy.id)

			--end if
		end
		--end loop
	end
end

return enemies
