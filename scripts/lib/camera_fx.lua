local const     = require("scripts.lib.const")
local data      = require("scripts.lib.data")

local camera_fx = {}

-- Shake
local shake     = {
    duration = 0,
    intensity = 0,
    decay = 0.9,
    offset = vmath.vector3()
}

function camera_fx.shake(intensity, duration, decay)
    shake.intensity = intensity or 0.5
    shake.duration = duration or 0.5
    shake.decay = decay or 0.9
end

function camera_fx.update(dt)
    local modified = false

    -- Shake effect
    if shake.duration > 0 then
        shake.offset.x = (rnd.double() - 0.5) * 2 * shake.intensity
        shake.offset.y = (rnd.double() - 0.5) * 2 * shake.intensity

        data.camera.position.x = data.camera.base_position.x + shake.offset.x
        data.camera.position.y = data.camera.base_position.y + shake.offset.y

        shake.intensity = shake.intensity * shake.decay
        shake.duration = shake.duration - dt
        if shake.duration <= 0 then
            shake.intensity = 0
        end
        modified = true
    end
    if modified then
        go.set_position(data.camera.position, const.URLS.CAMERA_ID)
    end
end

return camera_fx
