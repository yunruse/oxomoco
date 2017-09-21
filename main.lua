local yizzy = require 'yizzy'
local v = yizzy.vector.new
local setup = require 'setup'

local rend
local system

local rocket
local rotation
local thrust
local thrustvector = v{0, 0}

function love.load()
	
	-- load setup --
	
	rend = yizzy.render.new(setup)
	system = rend.system
	
	yizzy.core.log('Yizzy')
	
	-- controls --
	
	love.keyboard.setKeyRepeat(true)
	
	--rocket = system.bodies.earth
	rend.baseCamera = system.bodies.earth
	rend.bodyCamera = system.bodies.earth
	
	rotation = 0
	thrust = 0
end

function love.update(dt)
	if system.playing then
		thrustvector = thrustvector.fromPolar{rotation, value=thrust}
		system:update(dt, function()
			s.acc = s.acc + thrustvector
		end)
		rend:log(dt)
	end
end

---------------
-- rendering --
---------------

function love.draw()
	rend:draw()
	
	--[[ status --
	
	local bg = {50, 50, 50}
	if not system.playing then bg = {100, 50, 50} end
	love.graphics.setColor(bg)
	love.graphics.rectangle('fill', 0, 0, 300, 50)
	
	love.graphics.setColor{255,255,255}
	if system.playing then
		love.graphics.polygon('fill', 5, 5, 20, 15, 5, 25)
	else
		love.graphics.rectangle('fill', 5, 5, 5, 20)
		love.graphics.rectangle('fill', 15, 5, 5, 20)
	end
	
	love.graphics.print(string.format(
		' (%03.1e, %03.1e)\t×%.2e zoom \n time ×%.2e \n %d° at %d%% thrust',
		rend.camera[1], rend.camera[2], rend.zoom, system.timescale,
		rotation, thrust), 20, 0)
	
	-- ]]--
end

---------------
-- keyboard  --
---------------

local BACKGROUNDS = {
	['0'] = 'none',
	['1'] = 'grid',
	['2'] = 'gravity'
}

local TOGGLES = {
	t = 'showTitle',
	p = 'showPath',
	c = 'showConnections',
	v = 'showVector',
	b = 'showBody'
}

function love.keypressed(key)
	local toggle = TOGGLES[key]
	local bg = BACKGROUNDS[key]
	
	if toggle then
		rend[toggle] = not rend[toggle]
	
	elseif bg then
		rend.background = bg
	
	elseif key == 'space' then
		system.playing = not system.playing
	elseif key == 'f2' then
		rend:logGravityField()
	elseif key == 'f5' then
		love:load()
	elseif key == 'f11' then
		love.window.setFullscreen(not love.window.getFullscreen())
	elseif key == 'left' then
		rotation = rotation - 10
	elseif key == 'right' then
		rotation = rotation + 10
	elseif key == 'up' then
		thrust = thrust + 20
	elseif key == 'down' then
		thrust = thrust - 20
	else
		love.window.setTitle(key)
	end
	rotation = rotation % 360
	thrust = math.min(math.max(thrust, 0), 100)
end

-----------
-- mouse --
-----------

local movingBody = nil

function love.mousepressed(x, y, button, istouch)
	local body = rend:bodyAt{x, y}
	
	if button == 1 then
		if not system.playing then
			movingBody = body
		else
			movingBody = nil
		end
	elseif button == 2 then
		if love.keyboard.isDown('lshift', 'rshift') then
			rend.baseCamera = body
		end
		rend.bodyCamera = body
	end
end

function love.mousereleased(x, y, button, istouch)
	
end

function love.mousemoved(x, y, dx, dy, istouch)
	offset = v{dx, dy} / rend.zoom
	
	if love.mouse.isDown(1) and movingBody then
		movingBody.pos = movingBody.pos + offset
		
	elseif love.mouse.isDown(2) then
		-- camera motion
		rend.bodyCamera = nil
		rend.camera = rend.camera - offset
	
	elseif love.mouse.isDown(3) then
		rend.zoom = rend.zoom * 1.01 ^ dy
	end
end

function love.wheelmoved(x, y)
	local multiply = 1.2 ^ y
	if love.keyboard.isDown('lshift', 'rshift') then
		system.timescale = system.timescale * multiply
	else
		rend.zoom = rend.zoom * multiply
	end
end