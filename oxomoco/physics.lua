local oxomoco = {
    core = require 'oxomoco.core',
    vector = require 'oxomoco.vector',
}

local V = oxomoco.vector.new

oxomoco.physics = {

Body = oxomoco.core.class{
    __name = 'oxomoco.physics.Body',

    __defaults = {
        name = "",
        mass = 1,
        charge = 0,
        radius = 0,
        color = {255, 255, 255},
        pos = V{0, 0},
        vel = V{0, 0},
        acc = V{0, 0}
    },

    __init = function(self)
        self.pos = V(self.pos)
        self.vel = V(self.vel)
        self.acc = V(self.acc)
    end,

    e_k = function(self)
        return self.mass * self.vel:value2() / 2
    end
},

G = 6.67408e-11,

gravityForce = function(a, b)
    return -oxomoco.physics.G * a.mass * b.mass / a.pos.distance2(b.pos)
end,

Coulomb = 8.99 * 10 ^ 9,

electricForce = function(a, b)
    return oxomoco.physics.Coulomb * a.charge * b.charge / a.pos.distance2(b.pos)
end,

System = oxomoco.core.class{
    __name = 'oxomoco.physics.System',

    __init = function(self)
        for name, body in pairs(self.bodies) do
            self.bodies[name] = oxomoco.physics.Body.new(body)
            body.name = name
        end
    end,

    __defaults = {
        -- state
        bodies = {},
        playing = true,
        timescale = 1,
        dtlimit = 0.5
    },

    fieldStrength = function(self, coord, force)
        force = force or 'gravity'
        coord = V(coord)
        local acc = V{0, 0}
        for name, body in pairs(self.bodies) do
            local distance = coord - body.pos
            local distance2 = distance:value2()
            if distance2 > 0.1 then
                -- try not to divide by crazy amounts
                local factor
                if force == 'gravity' then
                    factor = -oxomoco.physics.G * body.mass
                else
                    -- Field is defined for a charge of +1
                    factor = oxomoco.physics.Coulomb * body.charge
                end
                acc = acc + distance * (factor / distance2)
            end
        end
        return acc
    end,

    update = function(self, dt, customforce)
        if dt > self.dtlimit or not self.playing then return end
        dt = dt * self.timescale

        for i, body in pairs(self.bodies) do
            body.acc = self:fieldStrength(body.pos, 'gravity')
                     + self:fieldStrength(body.pos, 'charge') * body.charge
        end

        pcall(customforce)

        for i, body in pairs(self.bodies) do
            body.vel = body.vel + body.acc * dt
            body.pos = body.pos + body.vel * dt
        end
    end,
}
}

return oxomoco.physics