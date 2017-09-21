local yizzy = {
	core = require 'yizzy.core',
	vector = require 'yizzy.vector',
	physics = {}
}

local V = yizzy.vector.new

yizzy.physics.Body = yizzy.core.class{
	__name = 'yizzy.physics.Body',
	
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
	end
}

yizzy.physics.G = 6.67408

yizzy.physics.gravityForce = function(self, a, b)
	return yizzy.physics.G * a.mass * b.mass / a.pos.distance2(b.pos)
end


yizzy.physics.System = yizzy.core.class{
	__name = 'yizzy.physics.System',
	
	__init = function(self)
		for name, body in pairs(self.bodies) do
			self.bodies[name] = yizzy.physics.Body.new(body)
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
	
	gravityFieldStrength = function(self, coord)
		coord = V(coord)
		local acc = V{0, 0}
		for name, body in pairs(self.bodies) do
			local distance = body.pos - coord
			local distance2 = distance:value2()
			if distance2 > 0.1 then
				-- try not to divide by crazy amounts
				local force = yizzy.physics.G * body.mass / distance2
				acc = acc + (distance * force)
			end
		end
		return acc
	end,
	
	update = function(self, dt, customforce)
		if dt > self.dtlimit or not self.playing then return end
		dt = dt * self.timescale
		
		for i, body in pairs(self.bodies) do
			body.acc = self:gravityFieldStrength(body.pos)
		end
		
		pcall(customforce)
		
		for i, body in pairs(self.bodies) do
			body.vel = body.vel + body.acc * dt
			body.pos = body.pos + body.vel * dt
		end
	end,
}

return yizzy.physics