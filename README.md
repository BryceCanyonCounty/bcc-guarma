# BCC Guarma

#### Description
Time to get away from the hustle and bustle of city life? Take a cruise to Guarma and relax for awhile.

#### Features
- Buy passage to travel between Guarma and Saint Denis
- Cash or gold may be used for payments
- Port hours may be set individually for each port or disabled to allow the port to remain open
- Port blips are colored and changeable for each location
- Blips can change color reflecting if port is open, closed or job locked
- Port access can be limited by job and jobgrade

#### Configuration
Settings can be changed in the `config.lua` file. Here is an example of Saint Denis Port:
```lua
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
    }
```

#### Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)

#### Installation
- Ensure that the dependancies are added and started
- Add `bcc-guarma` folder to your resources folder
- Add `ensure bcc-guarma` to your `resources.cfg`
