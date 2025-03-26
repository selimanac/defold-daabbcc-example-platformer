local collision          = require("scripts.lib.collision")
local const              = require("scripts.lib.const")
local audio              = require("scripts.lib.audio")

local particles          = {}

local GRAVITY            = -900
local DEFAULT_LIFETIME   = 1.0
local TINT_OFFSET        = vmath.vector4(1, 1, 1, 3)

local spawned_particles  = {}

local temp_part_id       = hash("")
local temp_position      = vmath.vector3()
local temp_sprite_url    = msg.url()
local temp_sprite_size   = vmath.vector3()
local temp_angle         = 0
local temp_speed         = 0
local temp_collision_bit = 0
local temp_aabb_id       = 0


function particles.spawn(ids, count, gravity, life_time, collectable)
	count = count or 4
	gravity = gravity or GRAVITY
	life_time = life_time or DEFAULT_LIFETIME
	collectable = collectable or false

	audio.play(const.AUDIO.PIECE_DROP)

	for i = 1, count do
		temp_part_id = ids[hash("/part" .. i)]
		temp_position = go.get_position(temp_part_id)
		temp_position.z = 0
		temp_sprite_url = msg.url(temp_part_id)
		temp_sprite_url.fragment = "sprite"

		temp_sprite_size = go.get(temp_sprite_url, "size")

		temp_angle = math.rad(rnd.range(70, 110)) --rnd.double() * math.pi
		temp_speed = rnd.range(150, 250)
		temp_collision_bit = collectable and const.COLLISION_BITS.PROP or const.COLLISION_BITS.PARTICLES
		temp_aabb_id = collision.insert_gameobject(temp_part_id, temp_sprite_size.x, temp_sprite_size.y, temp_collision_bit, false)

		local particle = {
			position = temp_position,
			velocity = vmath.vector3(math.cos(temp_angle) * temp_speed, math.sin(temp_angle) * temp_speed, 0),
			life_time = DEFAULT_LIFETIME,
			id = temp_part_id,
			aabb_id = temp_aabb_id,
			sprite_size = temp_sprite_size,
			on_ground = false,
			sprite_url = temp_sprite_url,
			active = true,
			collectable = collectable,
			gravity = gravity,
			hit_ground = false
		}
		spawned_particles[temp_aabb_id] = particle
	end
end

function particles.update(dt)
	for aabb_id, particle in pairs(spawned_particles) do
		particle.velocity.y = particle.velocity.y + particle.gravity * dt
		particle.position = particle.position + particle.velocity * dt
		particle.life_time = particle.life_time - dt

		if particle.on_ground == false then
			collision.update_aabb(particle.aabb_id, particle.position.x, particle.position.y, particle.sprite_size.x, particle.sprite_size.y)
			local result, count = collision.query_id(particle.aabb_id, const.COLLISION_BITS.TILE, true)

			if count > 0 then
				for i = 1, count do
					local offset_x = result[i].normal_x * result[i].depth
					local offset_y = result[i].normal_y * result[i].depth

					if (result[i].normal_x == 1 or result[i].normal_x == -1) then
						particle.velocity.x = 0
					end
					if result[i].normal_y == 1 then
						particle.on_ground = true
					end

					particle.position.x = particle.position.x + offset_x
					particle.position.y = particle.position.y + offset_y
				end
			end

			go.set_position(particle.position, particle.id)
		end

		if particle.on_ground and particle.collectable == false then
			if not particle.hit_ground then
				particle.hit_ground = true
				audio.play(const.AUDIO.PIECE_DROP)
			end
			if particle.life_time <= 0 and particle.active == true then
				particle.active = false

				go.animate(particle.sprite_url, "tint", go.PLAYBACK_ONCE_PINGPONG, TINT_OFFSET, go.EASING_INCIRC, 0.2, 0, function()
					collision.remove(particle.aabb_id)
					go.delete(particle.id, true)
					spawned_particles[aabb_id] = nil
				end)
			end
		end
	end
end

function particles.final()
	for _, particle in pairs(spawned_particles) do
		go.delete(particle.id)
	end
	spawned_particles = {}
end

return particles
