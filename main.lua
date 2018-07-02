-- This script is extremely janky - it's for debugging more than anything else at the moment.


local yizzy = require 'yizzy'
local v = yizzy.vector.new
local setup = require 'setup'

local rend
local system

local mode = 'camera'
local showDebug = true

function love.load()
	
	-- load setup --
	
	rend = yizzy.render.new(setup)
	system = rend.system
	
	yizzy.core.log('Yizzy')
	
	-- controls --
	
	love.keyboard.setKeyRepeat(true)
	
	rend.baseCamera = system.bodies.earth
	rend.bodyCamera = system.bodies.earth
end

function love.update(dt)
	if system.playing then
		system:update(dt)
		rend:log(dt)
	end
end

local _log = {}
local logger = function(text)
	if not text then return end
	table.insert(_log, {
		text = tostring(text),
		time = rend.timer})
end

---------------
-- rendering --
---------------

local MODES = {
	{
		mode = 'camera',
		key = '1',
		desc = '[1] Camera',
		help ='Left: Move or center camera\nRight: Make center of relativity'},
	{
		mode = 'manipulate',
		key = '2',
		desc = '[2] Manipulate',
		help = 'Left: Move body\tRight: change velocity of body\n(Must be paused to change.)'},
	{
		mode = 'place',
		key = '3',
		desc = '[3] Place',
		help = 'Left: place asteroid'},
	{
		mode = 'debug',
		key = '6',
		desc = '[6] Debug',
		help = 'Left: Show debug info'}
}

local drawDebug = function()
	local bg = {50, 50, 50}
	if not system.playing then bg = {100, 50, 50} end
	love.graphics.setColor(bg)
	love.graphics.rectangle('fill', 0, 0, 400, 100)
	
	love.graphics.setColor{255,255,255}
	if system.playing then
		love.graphics.polygon('fill', 5, 5, 20, 15, 5, 25)
	else
		love.graphics.rectangle('fill', 5, 5, 5, 20)
		love.graphics.rectangle('fill', 15, 5, 5, 20)
	end
	
	--love.graphics.print(string.format(
	--	' (%03.1e, %03.1e)\t×%.2e zoom \n time ×%.2e',
	--	rend.camera[1], rend.camera[2], rend.zoom, system.timescale), 20, 0)
		
	love.graphics.print(string.format(
		'Time: %04.fs (×10^%2f)',
		rend.timer, math.log10(rend.system.timescale)
	), 25, 0)
	
	-- mode controls --
	
	local controltext = {}
	local curmode = nil
	
	for i, m in ipairs(MODES) do
		if mode == m.mode then
			curmode = m
			table.insert(controltext, {255, 255, 0})
		else
			table.insert(controltext, {255, 255, 255})
		end
			
		table.insert(controltext, m.desc .. ' ')
	end
	
	love.graphics.printf(controltext, 25, 20, 300)
	
	love.graphics.print(curmode.help, 25, 40)
	
	-- log --
	
	local logtext = {}
	
	for i, log in ipairs(_log) do
		local fade = math.min(1, (log.time - (rend.timer - 6)))
		if fade > 0 then
			table.insert(logtext, {255, 255, 255, fade * 255})
			table.insert(logtext, log.text .. '\n')
		end
	end
	
	love.graphics.printf(logtext, 25, 105, 300)
end

function love.draw()
	rend:draw()
	
	if showDebug then
		drawDebug()
	end
end


---------------
-- keyboard  --
---------------


local MODES = {
	['1'] = 'camera',
	['2'] = 'manipulate',
	['3'] = 'place',
	['6'] = 'debug'
}

local BACKGROUNDS = {
	['9'] = 'grid',
	['8'] = 'gravity',
	['7'] = 'charge',
	['0'] = 'none'
}

local TOGGLES = {
	t = 'showTitle',
	p = 'showPath',
	c = 'showConnections',
	v = 'showVector',
	b = 'showBody'
}

function love.keypressed(key)
	rend.background = BACKGROUNDS[key] or rend.background
	mode = MODES[key] or mode
	
	local toggle = TOGGLES[key]
	if toggle then
		rend[toggle] = not rend[toggle]
	
	elseif bg then
		rend.background = bg
	
	elseif key == 'd' then
		showDebug = not showDebug
	elseif key == 'space' then
		system.playing = not system.playing
    elseif key == 'f2' then
        rend.gravField = rend:getFieldStrength('gravity')
	elseif key == 'f5' then
		love:load()
	elseif key == 'f11' then
		love.window.setFullscreen(not love.window.getFullscreen())
	end
end

-----------
-- mouse --
-----------

local movingBody = nil

local clickBody = function(body, state)
	
	if mode == 'manipulate' then
		if not system.playing then
			movingBody = body
		else
			movingBody = nil
		end
	elseif state == 'camera1' then
		rend.bodyCamera = body
	elseif state == 'camera2' then
		rend.baseCamera = body
	elseif state == 'debug1' then
		logger(string.format(
			'(%02.2e, %02.2e)', body.pos[1], body.pos[2]
			))
	end
end

local clickPoint = function(coord, state)
	if state == 'camera1' then
		rend.bodyCamera = nil
	elseif state == 'camera2' then
		rend.baseCamera = nil
	elseif state == 'place1' then
		if rend.baseCamera then
			vel = rend.baseCamera.vel
		else
			vel = {0, 0}
		end
		local new = yizzy.physics.Body.new{
			pos = rend:absCoord(coord),
			vel = vel,
			color = {127, 127, 127},
			name = 'asteroid',
			radius = 1,
			mass = 0}
		table.insert(system.bodies, new)
	end
end

function love.mousepressed(x, y, button, istouch)
	local coord = yizzy.vector.new{x, y}
	local body = rend:bodyAt(coord)
	local state = mode .. button
	
	if body then
		clickBody(body, state)
	else
		clickPoint(coord, state)
	end
end

function love.mousereleased(x, y, button, istouch)
	movingBody = nil
end

function love.mousemoved(x, y, dx, dy, istouch)
	offset = v{dx, dy} / rend.zoom
	
	if movingBody then
		if love.mouse.isDown(1) then
			movingBody.pos = movingBody.pos + offset
		elseif love.mouse.isDown(2) then
			movingBody.vel = movingBody.vel + offset
		end
	
	elseif love.mouse.isDown(1) and mode == 'camera' then
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