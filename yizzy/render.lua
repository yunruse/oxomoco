local yizzy = {
	core = require 'yizzy.core',
	vector = require 'yizzy.vector',
	physics = require 'yizzy.physics'
}

local V = yizzy.vector.new

_center = function(self)
	local width, height = love.graphics.getDimensions()
	return yizzy.vector.new{width, height} / 2
end

local GRAVITY = 6.67408

yizzy.render = yizzy.core.class{
	__name = 'yizzy.render',
	
	__defaults = {
		system = {},
		
		camera = V{0, 0},
		baseCamera = nil,
		bodyCamera = nil,
		zoom = 1,
		paths = {},
		timer = 0,
		
		--
		recordPath = true,
		recordEvery = 0.1,
		
		-- background
		background = 'none',
		-- 'grid'
		gridWidth = 100,
		-- all fields ('gravity')
		fieldPrecision = 10,
		
		-- components
		showPath = true,
		showBody = true,
		showTitle = true,
		showVector = true
	},
	
	__init = function(self)
		self.system = yizzy.physics.System.new(self.system)
	end,
	
	-----------------
	-- coordinates --
	-----------------
	
	visCoord = function(self, coord)
		return _center() + (V(coord) - self.camera) * self.zoom
	end,
	
	absCoord = function(self, coord)
		coord = yizzy.vector.new(coord)
		return ((coord - _center()) / self.zoom) + self.camera
	end,
	
	bodyAt = function(self, coord)
		local coord = yizzy.vector.new(coord)
		for i, body in pairs(self.system.bodies) do
			local b = self:visCoord(body.pos)
			local c = coord - b
			local d = c:value()
			if coord:distance(b) < body.radius * self.zoom then
				return body
			end
		end
	end,
	
	logPath = function(self, dt)
		dt = dt * self.system.timescale
		self.timer = self.timer + dt
		if self.timer > self.recordEvery then
			self.timer = self.timer - self.recordEvery
		else
			return
		end
		
		local snap = {}
		for name, body in pairs(self.system.bodies) do
			snap[name] = yizzy.core.copy(body.pos)
		end
		table.insert(self.paths, snap)
	end,
	
	------------
	-- render --
	------------

	draw = function(self)
		if self.bodyCamera then
			self.camera = self.bodyCamera.pos
		end
		local bg = self.background
		if bg == 'gravity' then
			self:drawField(yizzy.physics.System.gravityFieldStrength)
		elseif bg == 'grid' then
			self:drawGrid()
		end
		
		if self.showConnections then
			for i, pair in ipairs(yizzy.core.pairings(self.system.bodies)) do
				self:drawConnection(pair)
			end
		end
		for n, body in pairs(self.system.bodies) do
			if self.showBody then
				self:drawBody(body)
			end
			if self.showPath then
				self:drawBodyPath(body)
			end
		end
	end,

	drawField = function(self, func)
		local width, height = love.graphics.getDimensions()
		local pr = self.fieldPrecision
		local square = V{pr, pr}
		
		for x = 0, width / pr do
			for y = 0, height / pr do
				local a = V{x, y} * pr
				local b = a + square
				local center = self:absCoord(a + square / 2)
				
				local s = func(self.system, center):value() * 10
				love.graphics.setColor{s, s, s}
				
				love.graphics.rectangle('fill', a[1], a[2], b[1], b[2])
			end
		end
	end,
	
	drawGrid = function(self)
		-- todo: make a fancy af zoomyboy
		local width, height = love.graphics.getDimensions()
		local center = {0, 0}
		if self.baseCamera then
			center = self.baseCamera.pos
		end
		center = self:visCoord(center)
		
		local g = self.gridWidth * self.zoom
		local zoominess = math.log10(self.zoom)
		local step = -math.floor(zoominess)
		local large = g * 10 ^ (step)
		local small = g * 10 ^ (step - 1)
		
		local fade = zoominess % 1
		
		
		love.graphics.setLineWidth(0.5 + 0.5 * fade)
		local c = 50 * fade
		love.graphics.setColor{c,c,c}
		
		local x = center[1] % small % width
		while x < width do
			love.graphics.line(x, 0, x, height)
			x = x + small
		end
		local y = center[2] % small % height
		while y < height do
			love.graphics.line(0, y, width, y)
			y = y + small
		end
		
		love.graphics.setLineWidth(1)
		love.graphics.setColor{50,50,50}
		
		local x = center[1] % large % width
		while x < width do
			love.graphics.line(x, 0, x, height)
			x = x + large
		end
		local y = center[2] % large % height
		while y < height do
			love.graphics.line(0, y, width, y)
			y = y + large
		end
	end,
	
	-- todo: we're cleverer than this, do something fancy
	--       like system:getGravityForce(body1, body2):Magnitude()
	--       with vectors
	drawConnection = function(self, pair)
		-- oh man oh jeez coordinates suck
		a = pair[1].pos
		b = pair[2].pos
		
		local g = GRAVITY * pair[1].mass * pair[2].mass / a:distance2(b)
		
		a = self:visCoord(a)
		b = self:visCoord(b)
		
		love.graphics.setLineWidth(1)
		love.graphics.setColor{50,50,50}
		love.graphics.line(a[1], a[2], b[1], b[2])
		
		-- center to label
		local c = a + (b - a)/2
		local text = string.format("%.2fmN", g*1000)
		love.graphics.setColor{127, 127, 127}
		love.graphics.print(text, c[1], c[2])
	end,

	drawBodyPath = function(self, body)
		if #self.paths <= 1 then return end
		
		local visPath = {}
		for i, snap in ipairs(self.paths) do
			local pos = snap[body.name]
			if self.baseCamera then
				pos = self.baseCamera.pos + pos - snap[self.baseCamera.name]
			end
			local vis = self.visCoord(self, pos)
			table.insert(visPath, vis[1])
			table.insert(visPath, vis[2])
		end
		
		love.graphics.setColor(body.color)
		love.graphics.setLineWidth(1)
		love.graphics.line(visPath)
	end,
	
	drawBody = function(self, body)
		local visPos = self:visCoord(body.pos)
		local radius = body.radius * self.zoom
		
		
		-- check bounding box (you know circles can get mighty large)
		local n = visPos[2] - radius
		local s = visPos[2] + radius
		if s < 0 or n > love.graphics.getHeight() then return end
		
		local w = visPos[1] - radius
		local e = visPos[1] + radius
		if e < 0 or w > love.graphics.getWidth() then return end
		-- end check
		
		
		love.graphics.setColor(body.color)
		love.graphics.circle('fill', visPos[1], visPos[2], radius)
		
		if self.showTitle then
			local debugtext = string.format("%s", body.name)
			love.graphics.print(debugtext, visPos[1]-5, visPos[2] + radius + 2)
		end
		
		if self.showVector then
			local vel = body.vel
			if self.baseCamera then
				vel = vel - self.baseCamera.vel
			end
			local n = visPos + (vel * self.zoom * self.system.timescale)
			
			love.graphics.setColor{25, 25, 25}
			love.graphics.line(visPos[1], visPos[2], n[1], n[2])
		end
	end
}

return yizzy.render