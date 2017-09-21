local yizzy = {
	core = require 'yizzy.core'
}

yizzy.vector = yizzy.core.class{
	__name = 'yizzy.vector',
	
	__tostring = function(self)
		text = 'vector<'
		for i = 1, #self do
			if i ~= 1 then
				text = text .. ','
			end
			text = text .. self[i]
		end
		return text .. '>'
	end,
	
	validate = function(self, other)
		if not yizzy.core.isInstance(other, {'table', yizzy.vector}) then
			error(string.format(
				"vector or table expected, got %s", yizzy.core.type(other)), 3)
			return false
		elseif #self ~= #other then
			error(string.format(
				"incompatible dimensions (%s and %s)", #self, #other), 3)
			return false
		end
		return true
	end,
	
	compatible = function(self, other)
		return pcall(function() return self:validate(other) end) or false
	end,
	
	__add = function(self, other)
		self:validate(other)
		local new = yizzy.vector.new{}
		for d = 1, #self do
			new[d] = self[d] + other[d]
		end
		return new
	end,
	
	__sub = function(self, other)
		self:validate(other)
		local new = yizzy.vector.new{}
		for d = 1, #self do
			new[d] = self[d] - other[d]
		end
		return new
	end,
	
	__mul = function(self, other)
		local new = yizzy.vector.new{}
		if type(other) == 'number' then
			for d = 1, #self do
				new[d] = self[d] * other
			end
			return new
		else
			-- todo: implement vector multiplications
			error('NotImplemented: vector multiplication', 2)
		end
	end,
	
	__div = function(self, other)
		local new = yizzy.vector.new{}
		if type(other) == 'number' then
			for d = 1, #self do
				new[d] = self[d] / other
			end
			return new
		else
			error('can only divide vector by number', 2)
		end
	end,
	
	value2 = function(self)
		local total = 0
		for d = 1, #self do
			total = total + self[d]^2
		end
		return total
	end,
	
	value = function(self)
		return math.sqrt(self:value2())
	end,
	
	distance2 = function(self, other)
		self:validate(other)
		return (self - other):value2()
	end,
	
	distance = function(self, other)
		self:validate(other)
		return (self - other):value()
	end,
	
	argument = function(self)
		if #self == 2 then
			return math.atan2(self[2], self[1])
		else
			-- todo: maybe implement 3d as {alpha, beta, gamma ...} ?
			error('NotImplemented: argument of 3d+ vector', 2)
		end
	end,
	
	toPolar = function(self)
		local polar = self:argument()
		polar.value = self:value()
		return polar
	end,
	
	fromPolar = function(polar)
		if #polar == 1 then
			local theta = polar[1]
			return yizzy.vector.new{
				polar.value * math.sin(theta),
				polar.value * math.cos(theta)
			}
		else
			error('NotImplemented: argument of 3d+ vector', 2)
		end
	end
}

return yizzy.vector