Config = {}

Config.defaultlang = "en_lang"

Config.key = 0x760A9C6F --[G]

-- Travel Time in Milliseconds Between Locations
Config.travelTime = 15000 -- Default: 15000ms = 15 Seconds

-- Allow Blip on Map when Port is Closed
Config.blipAllowedClosed = true -- true = Show Closed Blip / false = Remove Blip

Config.ports = {
    stdenis = {
        portName = "Saint Denis Port", -- Name of Port on Menu Header
        promptName = "Saint Denis Port", -- Text Below the Prompt Button
        blipAllowed = true,-- Turns Blip On / Off
        blipName = "Saint Denis Port", -- Name of the Blip on the Map
        blipSprite = 2033397166, -- Default: 2033397166 (Paddleboat)
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32", -- Port Open - Default: White - Blip Colors Shown Below
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10", -- Port Closed - Deafault: Red
        blipColorJob = "BLIP_MODIFIER_MP_COLOR_23", -- Port Job Locked - Default: Yellow
        npc = {x = 2662.75, y = -1542.85, z = 45.92, h = 246.19}, -- NPC and Port Blip Position
        player = {x = 2664.32, y = -1544.26, z = 45.92, h = 269.93}, -- Player Landing Position
        distPort = 2.0, -- Distance from NPC to Get Menu Prompt
        npcAllowed = true, -- Turns NPCs On / Off
        npcModel = "s_m_m_sdticketseller_01", -- Sets Model for NPCs
        allowedJobs = {}, -- Empty, Everyone Can Use / Insert Job to limit access - ex. "police"
        jobGrade = 0, -- Enter Minimum Rank / Job Grade to Access Port
        portHours = false, -- If You Want the Shops to Use Open and Closed Hours
        portOpen = 7, -- Port Open Time / 24 Hour Clock
        portClose = 21, -- Port Close Time / 24 Hour Clock
        tickets = { -- label is the name used in the body of the menu / currencyType = "cash" or "gold" / DO NOT CHANGE "location"
            { label = 'Guarma', location = 'guarma', currencyType = "cash", buyPrice = 25, sellPrice = 15 }
        }
    },
    guarma = {
        portName = "Guarma Port",
        promptName = "Guarma Port",
        blipAllowed = true,
        blipName = "Guarma Port",
        blipSprite = 2033397166,
        blipColorOpen = "BLIP_MODIFIER_MP_COLOR_32",
        blipColorClosed = "BLIP_MODIFIER_MP_COLOR_10",
        blipColorJob = "BLIP_MODIFIER_MP_COLOR_23",
        npc = {x = 1266.51, y = -6852.67, z = 43.27, h = 236.72},
        player = {x = 1268.36, y = -6853.66, z = 43.27, h = 243.09},
        distPort = 2.0,
        npcAllowed = true,
        npcModel = "s_m_m_sdticketseller_01",
        allowedJobs = {},
        jobGrade = 0,
        portHours = false,
        portOpen = 7,
        portClose = 21,
        tickets = {
            { label = 'Saint Denis', location = 'stdenis', currencyType = "cash", buyPrice = 25, sellPrice = 15 }
        }
    }
}

--[[--------BLIP_COLORS----------
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
WHITE         = 'BLIP_MODIFIER_MP_COLOR_32']]