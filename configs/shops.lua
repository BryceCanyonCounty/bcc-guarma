-----------------------------------------------------
-- Travel Source Locations (these travel TO Guarma)
-----------------------------------------------------

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
            amount = 25,         -- Amount of Cash, Gold or Items
            item = {
                name = 'apple',  -- Item Name in Database
                label = 'Apple', -- Item Label in Database
                remove = true,   -- true = consume item, false = just check for presence
            }
        }
    },
    -----------------------------------------------------

    annesburg = {
        shop = {
            name        = 'Annesburg Port',      -- Used while Traveling and in Closed Shop Message
            prompt      = 'Annesburg to Guarma', -- Text Below the Menu Prompt Button
            distance    = 2.0,                   -- Distance Between Player and Shop to Show Menu Prompt
            jobsEnabled = false,                 -- Allow Shop Access to Specified Jobs Only
            jobs        = {                      -- Insert Job to Limit Access - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
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
            name   = 'Annesburg Port', -- Name of Blip on Map
            sprite = 2033397166,       -- Default: 2033397166
            show   = {
                open   = true,         -- Show Blip On Map when Open
                closed = true,         -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Shop Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                            -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',       -- Model Used for NPC
            coords   = vector3(3010.42, 1324.44, 42.7), -- NPC and Shop Blip Positions
            heading  = 329.62,                          -- NPC Heading
            distance = 100                              -- Distance Between Player and Shop for NPC to Spawn
        },
        player = {
            coords  = vector3(3010.89, 1326.0, 42.72), -- Player Teleport Position
            heading = 336.51                           -- Player Heading
        },
        travel = {
            location = 'guarma', -- DO NOT CHANGE LOCATION
            time = 15            -- Travel Time in Seconds
        },
        price = {
            currency = 1,        -- 1 = cash, 2 = gold, 3 = item
            amount = 30,         -- Amount of Cash, Gold or Items
            item = {
                name = 'apple',  -- Item Name in Database
                label = 'Apple', -- Item Label in Database
                remove = true,   -- true = consume item, false = just check for presence
            }
        }
    },
    -----------------------------------------------------

    quakerscove = {
        shop = {
            name        = 'Quakers Cove Port',      -- Used while Traveling and in Closed Shop Message
            prompt      = 'Quakers Cove to Guarma', -- Text Below the Menu Prompt Button
            distance    = 2.0,                      -- Distance Between Player and Shop to Show Menu Prompt
            jobsEnabled = false,                    -- Allow Shop Access to Specified Jobs Only
            jobs        = {                         -- Insert Job to Limit Access - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
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
            name   = 'Quakers Cove Port', -- Name of Blip on Map
            sprite = 2033397166,          -- Default: 2033397166
            show   = {
                open   = true,            -- Show Blip On Map when Open
                closed = true,            -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Shop Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Shop Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Shop Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                               -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',          -- Model Used for NPC
            coords   = vector3(-1173.38, -1968.98, 42.34), -- NPC and Shop Blip Positions
            heading  = 81.4,                               -- NPC Heading
            distance = 100                                 -- Distance Between Player and Shop for NPC to Spawn
        },
        player = {
            coords  = vector3(-1174.78, -1968.54, 42.36), -- Player Teleport Position
            heading = 72.19                               -- Player Heading
        },
        travel = {
            location = 'guarma', -- DO NOT CHANGE LOCATION
            time = 20            -- Travel Time in Seconds
        },
        price = {
            currency = 1,        -- 1 = cash, 2 = gold, 3 = item
            amount = 35,         -- Amount of Cash, Gold or Items
            item = {
                name = 'apple',  -- Item Name in Database
                label = 'Apple', -- Item Label in Database
                remove = true,   -- true = consume item, false = just check for presence
            }
        }
    },
    -----------------------------------------------------
    -- Add more shops as needed
}

-----------------------------------------------------
-- Guarma Destination (special menu-based system)
-----------------------------------------------------

Guarma = {
    shop = {
        name        = 'Guarma Port',      -- Used while Traveling and in Closed Shop Message
        prompt      = 'Open Travel Menu', -- Text Below the Menu Prompt Button
        distance    = 2.0,                -- Distance Between Player and Shop to Show Menu Prompt
        jobsEnabled = false,              -- Allow Shop Access to Specified Jobs Only
        jobs        = {                   -- Insert Job to Limit Access - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
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
    price = {
        currency = 1,        -- 1 = cash, 2 = gold, 3 = item
        amount = 25,         -- Amount of Cash, Gold or Items
        item = {
            name = 'apple',  -- Item Name in Database
            label = 'Apple', -- Item Label in Database
            remove = true,   -- true = consume item, false = just check for presence
        }
    }
}
