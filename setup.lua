local oxomoco = require 'oxomoco'

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

    zoom = 10 ^ -9,

    background = 'grid',
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
                mass = 1.98e30,
                radius = 695508
            },
            earth = {
                color = {0, 255, 255},
                mass = 5.97e24,
                radius = 6371, 
                pos = {1.496e11, 0},
                vel = {0, 11500000000}
            },
            moon = {
                color = {127, 127, 127},
                mass = 7.34e22,
                radius = 1737.5,
                pos = {1.5e11, 0},
                vel = {0, 11501022000}
            }
        }
    }
}

local mars = {
    recordPath = true,

    zoom = 10 ^ -5,

    background = 'grid',
    fieldPrecision = 10,

    gridWidth = 1.496 * 10 ^ 9,
    -- components
    showPath = true,
    showBody = true,
    showTitle = true,
    showVector = false,

    system = {
        bodies = {
            mars = {
                color = {127, 0, 0},
                pos={0, 0},
                vel={0, 0},
                mass = 6.4185e23,
                radius = 3389.5e3,
            },
            phobos = {
                color = {127, 127, 127},
                mass = 1.06e16,
                radius = 9.1e3, 
                pos = {9378000, 0},
                vel = {0, 6500000}
            },
            deimos = {
                color = {127, 127, 127},
                mass = 2.4e15,
                radius = 5.1e3, 
                pos = {23459000, 0},
                vel = {0, 6500000}
            }
        }
    }
}

local AU = 3

local solar = {
    zoom = 10 ^ -7,
    gridWidth = 1.496 * 10 ^ 9,
    
    system = { bodies = {
        sun = {
            color = {255, 255, 0},
            sattelites = {
                mercury = {
                    color = "#88aacc",
                    radius = 2539.7e3,
                    mass = 0.33e24,
                    semimajor = AU*0.38710,
                    eccentricity = 0.20563
                },
                venus = {
                    color = "#880088",
                    radius = 6051.8e3,
                    mass = 4.78e24,
                    semimajor = AU*0.72333,
                    eccentricity = 0.72333
                },
                earth = {
                    color = "#00ff00",
                    radius = 6371e3,
                    mass = 5.97e24,
                    semimajor = AU,
                    eccentricity = 0.01671,
                    sattelites = {
                        moon = {
                            color = "#00ff00",
                            radius = 6371e3,
                            mass = 5.97e24,
                            semimajor = AU,
                            eccentricity = 0.0167
                        }
                    }
                },
                mars = {
                    color = "#88aacc",
                    radius = 2539.7e3,
                    mass = 0.33e24,
                    semimajor = AU*1.52366,
                    eccentricity = 0.09341
                }
            }
        }
    }}
}

return mars