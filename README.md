# bcc-guarma

#### Description
Escape to paradise on the *Saint Denis-Guarma Express*, your ticket to the ultimate island getaway!
When you're ready to explore, head to the island and discover its many wonders. Relax on pristine beaches or hop in a boat *(bcc-boats)* to explore the coastline in calm waters.

#### Features
- Boat tickets are avilable in both Saint Denis and Guarma
- Tickets will be added to your inventory and can be used immediately or at a later time
- You can carry up to 4 tickets at a time (could make a nice gift for a friend)
- Port hours may be set individually for each port or disabled to allow the port to remain open
- Port blips are colored and changeable for each location
- Blips can change color reflecting if port is open, closed or job locked
- Port access can be limited by job and jobgrade
- Distance based NPC spawns

#### Configuration
Settings can be changed in the `config.lua` file. Here is an example of Saint Denis Port:
```lua
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
```

#### Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)

#### Installation
- Add `bcc-guarma` folder to your resources folder
- Add `ensure bcc-guarma` to your `resources.cfg`
- Run the included database file `guarma.sql`
- Add `boat_ticket` image to: `...\vorp_inventory\html\img`
- Restart server
