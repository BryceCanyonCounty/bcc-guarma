Config = {}

Config.defaultlang = 'en_lang'
-----------------------------------------------------

Config.keys = {
    buy    = 0xC7B5340A, --[Enter]
    travel = 0x760A9C6F  --[G]
}
-----------------------------------------------------

-- Travel Time in Seconds Between Locations
Config.travelTime = 15 -- Default: 15 Seconds
-----------------------------------------------------

-- Allow Blip on Map when Shop is Closed
Config.blipOnClosed = true -- true = Show Closed Blip / false = Remove Blip
-----------------------------------------------------

Config.shops = {
    stdenis = {
        shopName = 'Saint Denis Port', -- Name of Shop on Menu Header
        promptName = 'Saint Denis to Guarma', -- Text Below the Prompt Button
        blipOn = true,-- Turns Blip On / Off
        blipName = 'Saint Denis Port', -- Name of the Blip on the Map
        blipSprite = 2033397166, -- Default: 2033397166 (Paddleboat)
        blipColorOpen = 'WHITE', -- Shop Open - Default: White - Blip Colors Shown Below
        blipColorClosed = 'RED', -- Shop Closed - Default: Red
        blipColorJob = 'YELLOW_ORANGE', -- Shop Job Locked - Default: Yellow
        npc = {x = 2662.75, y = -1542.85, z = 44.92, h = 246.19}, -- NPC and Shop Blip Position
        player = {x = 2664.32, y = -1544.26, z = 45.92, h = 269.93}, -- Player Landing Position
        nDistance = 100.0, -- Distance from Shop for NPC to Spawn
        sDistance = 2.0, -- Distance from NPC to Show Prompts
        npcOn = true, -- Turns NPCs On / Off
        npcModel = 's_m_m_sdticketseller_01', -- Sets Model for NPCs
        allowedJobs = {}, -- Empty, Everyone Can Use / Insert Job to limit access - ex. "police"
        jobGrade = 0, -- Enter Minimum Rank / Job Grade to Access Shop
        shopHours = false, -- If You Want the Ports to Use Open and Closed Hours
        shopOpen = 7, -- Shop Open Time / 24 Hour Clock
        shopClose = 21, -- Shop Close Time / 24 Hour Clock
        tickets = { location = 'guarma', buyPrice = 25 } -- DO NOT CHANGE LOCATION
    },
    guarma = {
        shopName = 'Guarma Port',
        promptName = 'Guarma to Saint Denis',
        blipOn = true,
        blipName = 'Guarma Port',
        blipSprite = 2033397166,
        blipColorOpen = 'WHITE',
        blipColorClosed = 'RED',
        blipColorJob = 'YELLOW_ORANGE',
        npc = {x = 1266.51, y = -6852.67, z = 42.27, h = 236.72},
        player = {x = 1268.36, y = -6853.66, z = 43.27, h = 243.09},
        nDistance = 100.0,
        sDistance = 2.0,
        npcOn = true,
        npcModel = 's_m_m_sdticketseller_01',
        allowedJobs = {},
        jobGrade = 0,
        shopHours = false,
        shopOpen = 7,
        shopClose = 21,
        tickets = { location = 'stdenis', buyPrice = 25 }
    }
}
-----------------------------------------------------

Config.BlipColors = {
    LIGHT_BLUE    = 'BLIP_MODIFIER_MP_COLOR_1',
    DARK_RED      = 'BLIP_MODIFIER_MP_COLOR_2',
    PURPLE        = 'BLIP_MODIFIER_MP_COLOR_3',
    ORANGE        = 'BLIP_MODIFIER_MP_COLOR_4',
    TEAL          = 'BLIP_MODIFIER_MP_COLOR_5',
    LIGHT_YELLOW  = 'BLIP_MODIFIER_MP_COLOR_6',
    PINK          = 'BLIP_MODIFIER_MP_COLOR_7',
    GREEN         = 'BLIP_MODIFIER_MP_COLOR_8',
    DARK_TEAL     = 'BLIP_MODIFIER_MP_COLOR_9',
    RED           = 'BLIP_MODIFIER_MP_COLOR_10',
    LIGHT_GREEN   = 'BLIP_MODIFIER_MP_COLOR_11',
    TEAL2         = 'BLIP_MODIFIER_MP_COLOR_12',
    BLUE          = 'BLIP_MODIFIER_MP_COLOR_13',
    DARK_PUPLE    = 'BLIP_MODIFIER_MP_COLOR_14',
    DARK_PINK     = 'BLIP_MODIFIER_MP_COLOR_15',
    DARK_DARK_RED = 'BLIP_MODIFIER_MP_COLOR_16',
    GRAY          = 'BLIP_MODIFIER_MP_COLOR_17',
    PINKISH       = 'BLIP_MODIFIER_MP_COLOR_18',
    YELLOW_GREEN  = 'BLIP_MODIFIER_MP_COLOR_19',
    DARK_GREEN    = 'BLIP_MODIFIER_MP_COLOR_20',
    BRIGHT_BLUE   = 'BLIP_MODIFIER_MP_COLOR_21',
    BRIGHT_PURPLE = 'BLIP_MODIFIER_MP_COLOR_22',
    YELLOW_ORANGE = 'BLIP_MODIFIER_MP_COLOR_23',
    BLUE2         = 'BLIP_MODIFIER_MP_COLOR_24',
    TEAL3         = 'BLIP_MODIFIER_MP_COLOR_25',
    TAN           = 'BLIP_MODIFIER_MP_COLOR_26',
    OFF_WHITE     = 'BLIP_MODIFIER_MP_COLOR_27',
    LIGHT_YELLOW2 = 'BLIP_MODIFIER_MP_COLOR_28',
    LIGHT_PINK    = 'BLIP_MODIFIER_MP_COLOR_29',
    LIGHT_RED     = 'BLIP_MODIFIER_MP_COLOR_30',
    LIGHT_YELLOW3 = 'BLIP_MODIFIER_MP_COLOR_31',
    WHITE         = 'BLIP_MODIFIER_MP_COLOR_32'
}