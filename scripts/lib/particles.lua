local collision         = require("scripts.lib.collision")
local const             = require("scripts.lib.const")
local audio             = require("scripts.lib.audio")

local particles         = {}

local GRAVITY           = -900
local DEFAULT_LIFETIME  = 1.0

local spawned_particles = {}

function particles.spawn(ids, count, gravity, life_time, collectable)
	gravity = gravity or GRAVITY
	life_time = life_time or DEFAULT_LIFETIME
	collectable = collectable or false
	audio.play(const.AUDIO.PIECE_DROP)
	count = count or 4
	for i = 1, count do
		local part_id = ids[hash("/part" .. i)]
		local position = go.get_position(part_id)
		local sprite_url = msg.url(part_id)
		sprite_url.fragment = "sprite"

		local sprite_size = go.get(sprite_url, "size")

		local angle = math.rad(rnd.range(70, 110)) --rnd.double() * math.pi
		local speed = rnd.range(150, 250)
		local collision_bit = collectable and const.COLLISION_BITS.PROP or const.COLLISION_BITS.PARTICLES
		local aabb_id = collision.insert_gameobject(part_id, sprite_size.x, sprite_size.y, collision_bit, false)

		local particle = {
			pos = vmath.vector3(position.x, position.y, 0),
			vel = vmath.vector3(math.cos(angle) * speed, math.sin(angle) * speed, 0),
			life = DEFAULT_LIFETIME,
			id = part_id,
			aabb_id = aabb_id,
			sprite_size = sprite_size,
			on_ground = false,
			sprite_url = sprite_url,
			active = true,
			collectable = collectable,
			gravity = gravity,
			hit_ground = false

		}
		spawned_particles[aabb_id] = particle
	end
end

function particles.update(dt)
	for aabb_id, particle in pairs(spawned_particles) do
		particle.vel.y = particle.vel.y + particle.gravity * dt
		particle.pos = particle.pos + particle.vel * dt
		particle.life = particle.life - dt

		if particle.on_ground == false then
			collision.update_aabb(particle.aabb_id, particle.pos.x, particle.pos.y, particle.sprite_size.x, particle.sprite_size.y)
			local result, count = collision.query_id(particle.aabb_id, const.COLLISION_BITS.TILE, true)

			if count > 0 then
				for i = 1, count do
					local offset_x = result[i].normal_x * result[i].depth
					local offset_y = result[i].normal_y * result[i].depth

					if (result[i].normal_x == 1 or result[i].normal_x == -1) then
						particle.vel.x = 0
					end
					if result[i].normal_y == 1 then
						particle.on_ground = true
					end

					particle.pos.x = particle.pos.x + offset_x
					particle.pos.y = particle.pos.y + offset_y
				end
			end

			go.set_position(particle.pos, particle.id)
		end

		if particle.on_ground and particle.collectable == false then
			if not particle.hit_ground then
				particle.hit_ground = true
				audio.play(const.AUDIO.PIECE_DROP)
			end
			if particle.life <= 0 and particle.active == true then
				particle.active = false

				go.animate(particle.sprite_url, "tint", go.PLAYBACK_ONCE_PINGPONG, vmath.vector4(1, 1, 1, 3), go.EASING_INCIRC, 0.2, 0, function()
					collision.remove(particle.aabb_id)
					go.delete(particle.id)
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
