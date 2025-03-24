local const           = require("scripts.lib.const")
local data            = require("scripts.lib.data")
local collision       = require("scripts.lib.collision")
local utils           = require("scripts.lib.utils")
local entities        = require("scripts.lib.entities")

local enemies         = {}

local query_result    = {}
local enemy_direction = 0

function enemies.add(object_data, hflip, vflip, properties)
	hflip = hflip and hflip or false
	vflip = vflip and vflip or false

	-- Object rotation
	local rotation = utils.object_rotate(object_data)

	-- Copy from table
	local enemy = utils.table_copy(entities.ENEMY[object_data.name])

	enemy.name = object_data.name
	enemy.properties = properties
	enemy.center.x = object_data.x + (enemy.size.width / 2)
	enemy.center.y = (data.map_height - object_data.y) + (enemy.size.height / 2)
	enemy.position = vmath.vector3(enemy.center.x, enemy.center.y, 0.3)

	-- factory
	enemy.id = factory.create(enemy.factory, enemy.position, rotation)
	enemy.sprite = msg.url(enemy.id)
	enemy.sprite.fragment = "sprite"

	-- h - v flip
	utils.flip_object_sprite(enemy.sprite, hflip, vflip)

	-- rotate collider
	utils.rotate_object_collider(rotation, enemy)

	-- apply offset
	enemy.center.x = enemy.center.x - enemy.offset.x
	enemy.center.y = enemy.center.y - enemy.offset.y

	--inset aabb
	if not enemy.is_fixed then
		enemy.aabb_id = collision.insert_gameobject(enemy.id, enemy.collider_size.width, enemy.collider_size.height, enemy.collision_bit)
	else
		enemy.aabb_id = collision.insert_aabb(enemy.center.x, enemy.center.y, enemy.collider_size.width, enemy.collider_size.height, enemy.collision_bit)
	end

	enemy.state.is_idle = true

	--add to enemies table
	data.enemies[enemy.aabb_id] = enemy
end

function enemies.update(dt)
	for _, enemy in pairs(data.enemies) do
		if not enemy.is_fixed and enemy.status == false then
			go.set_position(enemy.position, enemy.id)

			if not enemy.state.is_moving then
				enemy.state.is_moving = true
				enemy.state.is_idle = false
				if enemy.anims.walk then
					sprite.play_flipbook(enemy.sprite, enemy.anims.walk)
				end
			end

			enemy.position.x = enemy.position.x + (enemy.properties.speed * enemy.properties.direction_x) * dt
			enemy.position.y = enemy.position.y + (enemy.properties.speed * enemy.properties.direction_y) * dt
			enemy.center = enemy.position

			-- Query directions
			query_result, _ = collision.query_id(enemy.aabb_id, const.COLLISION_BITS.DIRECTIONS)
			if query_result then
				enemy_direction = data.directions[query_result[1]]
				enemy.properties.direction_x = enemy_direction.direction_x
				enemy.properties.direction_y = enemy_direction.direction_y

				if enemy.is_flip then
					utils.flip_object_sprite(enemy.sprite, enemy.properties.direction_x, enemy.properties.direction_y)
				end
			end

			--end if
		end
		--end loop
	end
end

return enemies
