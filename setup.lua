local yizzy = require 'yizzy'

local solarBasic = {
	recordPath = true,
	
	zoom = 3,
	
	background = 'grid',
	fieldPrecision = 40,
	
	gridWidth = 100,
	-- components
	showPath = true,
	showBody = true,
	showTitle = true,
	showVector = false,
	
	system = {
		bodies = {
			sun = {
				color = {255, 255, 0},
				mass = 1000, --5.972*10^24,
				radius = 50
			},
			earth = {
				color = {0, 255, 255},
				mass = 100, --7.342*10^22,
				radius = 10, 
				pos = {3000, 0}, --384402000
				vel = {0, 84.5}
			},
			moon = {
				color = {127, 127, 127},
				mass = 3,
				radius = 1,
				pos = {3040, 0},
				vel = {0, 110.8}
			}
		}
	}
}

local solarReal = {
	recordPath = true,
	
	zoom = 10 ^ -20,
	
	background = 'gravity',
	fieldPrecision = 10,
	
	gridWidth = 1.496 * 10 ^ 9,
	-- components
	showPath = true,
	showBody = true,
	showTitle = true,
	showVector = false,
	
	system = {
		bodies = {
			sun = {
				color = {255, 255, 0},
				mass = 1.98 *(10^ 30),
				radius = 50
			},
			earth = {
				color = {0, 255, 255},
				mass = 5.97 *(10^ 24),
				radius = 10, 
				pos = {1.496 *10^ 11, 0},
				vel = {0, 29000000}
			}--[[,
			moon = {
				color = {127, 127, 127},
				mass = 7.34 *10^ 22,
				radius = 1,
				pos = {1.5 * 10^ 11, 0},
				vel = {0, 29800 + 1020}
			}]]--
		}
	}
}
return solarBasic