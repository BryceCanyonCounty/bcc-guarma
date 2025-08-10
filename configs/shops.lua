Shops = {
    stdenis = {
        shop = {
            name        = 'Saint Denis Port',      -- Used while Traveling and in Closed Shop Message
            prompt      = 'Saint Denis to Guarma', -- Text Below the Menu Prompt Button
            distance    = 2.0,                     -- Distance Between Player and Shop to Show Menu Prompt
            jobsEnabled = false,                   -- Allow Shop Access to Specified Jobs Only
            jobs        = {                        -- Insert Job to Limit Access - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'police', grade = 1 },
                { name = 'doctor', grade = 3 }
            },
            hours       = {
                active = false, -- Shop uses Open and Closed Hours
                open   = 7,     -- Shop Open Time / 24 Hour Clock
                close  = 21     -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Saint Denis Port', -- Name of Blip on Map
            sprite = 2033397166,         -- Default: 2033397166
            show   = {
                open   = true,           -- Show Blip On Map when Open
                closed = true,           -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Shop Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                              -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',         -- Model Used for NPC
            coords   = vector3(2662.75, -1542.85, 44.92), -- NPC and Shop Blip Positions
            heading  = 246.19,                            -- NPC Heading
            distance = 100                                -- Distance Between Player and Shop for NPC to Spawn
        },
        player = {
            coords  = vector3(2664.32, -1544.26, 45.92), -- Player Teleport Position
            heading = 269.93                             -- Player Heading
        },
        travel = {
            location = 'guarma', -- DO NOT CHANGE LOCATION
            time = 15            -- Travel Time in Seconds
        },
        price = {
            currency = 1,        -- 1 = cash, 2 = gold, 3 = item
            amount = 25,          -- Amount of Cash, Gold or Items
            item = {
                name = 'apple',  -- Item Name in Database
                label = 'Apple', -- Item Label in Database
            }
        }
    },
    -----------------------------------------------------

    guarma = {
        shop = {
            name        = 'Guarma Port',           -- Used while Traveling and in Closed Shop Message
            prompt      = 'Guarma to Saint Denis', -- Text Below the Menu Prompt Button
            distance    = 2.0,                     -- Distance Between Player and Shop to Show Menu Prompt
            jobsEnabled = false,                   -- Allow Shop Access to Specified Jobs Only
            jobs        = {                        -- Insert Job to Limit Access - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'police', grade = 1 },
                { name = 'doctor', grade = 3 }
            },
            hours       = {
                active = false, -- Shop uses Open and Closed Hours
                open   = 7,     -- Shop Open Time / 24 Hour Clock
                close  = 21     -- Shop Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Guarma Port', -- Name of Blip on Map
            sprite = 2033397166,    -- Default: 2033397166
            show   = {
                open   = true,      -- Show Blip On Map when Open
                closed = true,      -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Shop Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                             -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',        -- Model Used for NPC
            coords   = vector3(1286.86, -6859.87, 43.1), -- NPC and Shop Blip Positions
            heading  = 190.06,                           -- NPC Heading
            distance = 100                               -- Distance Between Player and Shop for NPC to Spawn
        },
        player = {
            coords  = vector3(1286.81, -6861.14, 43.15), -- Player Teleport Position
            heading = 15.14                              -- Player Heading
        },
        travel = {
            location = 'stdenis', -- DO NOT CHANGE LOCATION
            time = 15             -- Travel Time in Seconds
        },
        price = {
            currency = 1,        -- 1 = cash, 2 = gold, 3 = item
            amount = 25,          -- Amount of Cash, Gold or Items
            item = {
                name = 'apple',  -- Item Name in Database
                label = 'Apple', -- Item Label in Database
            }
        }
    }
}