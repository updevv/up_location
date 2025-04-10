-----------------------------------------------------
--                                                   -
--     Discord: https://discord.gg/updev             -
--                                                   -
-----------------------------------------------------

Config = Config or {}


Config = {
    LocationTime = 2, -- En minutes
    BlipSprite = 85,
    BlipScale = 1.0,
    BlipColor = 3,
    PedModel = "a_m_m_beach_01",
    LocationVehicle = {
        ['blista'] = {model = "blista", label = "Blista", price = 1000},
        ['panto'] = {model = "panto", label = "Panto", price = 1000},
    },
    LocationCoords = {
        [1] = {coords = vector3(221.40, -860.43, 30.17), coordspawn = vector3(227.78, -865.00, 30.30), heading = 90},
    }
}
