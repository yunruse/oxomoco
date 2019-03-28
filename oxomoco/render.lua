-- Visualisation and display functions.

local oxomoco = {
    core = require 'oxomoco.core',
    vector = require 'oxomoco.vector',
    physics = require 'oxomoco.physics'
}

local V = oxomoco.vector.new

_center = function(self)
    local width, height = love.graphics.getDimensions()
    return V{width, height} / 2
end

oxomoco.render = oxomoco.core.class{
    __name = 'oxomoco.render',

    __defaults = {
        system = {},

        camera = V{0, 0},
        baseCamera = nil,
        bodyCamera = nil,
        zoom = 1,
        paths = {},
        timer = 0,
        stepTimer = 0,

        gravField = {},

        --
        recordPath = true,
        recordEvery = 0.1,

        -- background
        background = 'none',

        gridGray = 63,
        -- all fields ('gravity')
        fieldPrecision = 2,

        -- components
        showPath = true,
        showBody = true,
        showTitle = true,
        showVector = true
    },

    __init = function(self)
        self.system = oxomoco.physics.System.new(self.system)
    end,

    -----------------
    -- coordinates --
    -----------------

    visCoord = function(self, coord)
        return _center() + (V(coord) - self.camera) * self.zoom
    end,

    absCoord = function(self, coord)
        coord = V(coord)
        return ((coord - _center()) / self.zoom) + self.camera
    end,

    bodyAt = function(self, coord)
        for i, body in pairs(self.system.bodies) do
            local distance = V(coord):distance(self:visCoord(body.pos))
            local radius = math.max(body.radius * self.zoom, 20)
            if distance < radius then    return body    end
        end
    end,

    body2At = function(self, coord)
        local coord = self:absCoord(coord)
        local radii = {}
        for i, body in pairs(self.system.bodies) do
            table.insert(radii, {
                body=body, radius=(coord - body.pos):value()
            })
        end
        table.sort(radii, function(a, b) return a.radius < b.radius end)
        return radii[1].body
    end,

    getFieldStrength = function(self, force)
        local pr = self.fieldPrecision
        local width, height = love.graphics.getDimensions()
        local square = V{pr, pr}
        local grid = {precision=pr, force=force}

        for x = 0, width / pr do
            local line = {}

            for y = 0, height / pr do
                local a = V{x, y} * pr
                local center = self:absCoord(a + square / 2)

                local intensity = self.system:fieldStrength(center, force):value()
                table.insert(line, intensity)
            end
            table.insert(grid, line)
        end

        return grid
    end,

    ---------
    -- log --
    ---------

    log = function(self, dt)
        self.timer = self.timer + dt

        self.stepTimer = self.stepTimer + dt
        if self.stepTimer > self.recordEvery then
            self.stepTimer = self.stepTimer - self.recordEvery
            self:logPath()
        end
    end,

    logPath = function(self)
        local snap = {}
        for name, body in pairs(self.system.bodies) do
            snap[name] = oxomoco.core.copy(body.pos)
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
        if bg == 'grid' then
            self:drawGrid()
        else
            self:drawField()
        end

        if self.showConnections then
            for i, pair in ipairs(oxomoco.core.pairings(self.system.bodies)) do
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

    drawField = function(self)
        local pr = self.fieldPrecision
        local square = V{pr, pr}
        for x, line in ipairs(self.gravField) do
            for y, intensity in ipairs(line) do
                local b = V{x, y} * pr
                local a = b - square
                local i = intensity / 100000
                love.graphics.setColor{i,i,i}
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

        local g = 100 * self.zoom
        local zoominess = math.log10(self.zoom)
        local step = -math.floor(zoominess)
        local large = g * 10 ^ (step)
        local small = large / 10

        local fade = zoominess % 1

        love.graphics.setLineWidth(0.5 + 0.5 * fade)
        local c = self.gridGray * fade
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
        love.graphics.setColor{self.gridGray, self.gridGray, self.gridGray}

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

    drawConnection = function(self, pair)
        love.graphics.setLineWidth(1)
        love.graphics.setColor{50,50,50}
        a = self:visCoord(pair[1].pos)
        b = self:visCoord(pair[2].pos)
        love.graphics.line(a[1], a[2], b[1], b[2])
    end,

    drawBodyPath = function(self, body)
        if #self.paths <= 1 then return end

        local visPath = {}
        for i, snap in ipairs(self.paths) do
            local pos = snap[body.name]
            if not pos then goto continue end

            if self.baseCamera then
                pos = self.baseCamera.pos + pos - snap[self.baseCamera.name]
            end
            local vis = self.visCoord(self, pos)
            table.insert(visPath, vis[1])
            table.insert(visPath, vis[2])

            ::continue::
        end

        love.graphics.setColor(body.color)
        love.graphics.setLineWidth(1)
        if #visPath > 2 then
            love.graphics.line(visPath)
        end
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

return oxomoco.render