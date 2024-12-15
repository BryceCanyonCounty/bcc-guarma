# bcc-guarma

#### Description
Escape to paradise on the *Saint Denis-Guarma Express*, your ticket to the ultimate island getaway!
When you're ready to explore, head to the island and discover its many wonders. Relax on pristine beaches or hop in a boat *(bcc-boats)* to explore the coastline in calm waters.

#### Features
- Boat tickets are avilable in both Saint Denis and Guarma
- Ticket price can be set using cash, gold or items
- Tickets will be added to your inventory and can be used immediately or at a later time
- You can carry up to 4 tickets at a time (could make a nice gift for a friend)
- Port hours may be set individually for each port or disabled to allow the port to remain open
- Port blips are colored and changeable for each location
- Blips can change color reflecting if port is open, closed or job locked
- Port access can be limited by job and jobgrade
- Distance based NPC spawns

#### Dependencies
- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)

#### Installation
- Make sure dependencies are installed/updated and ensured before this script
- Add `bcc-guarma` folder to your resources folder
- Add `ensure bcc-guarma` to your `resources.cfg`
- Run the included database file `guarma.sql`
- Add `boat_ticket` image to: `...\vorp_inventory\html\img`
- Restart server

#### Tips
- Add a respawn point for Guarma in vorp_core config `Hospitals` table. Example below.
    ```lua
    Guarma = {
        name = "Guarma",
        pos = vector4(1309.37, -6895.1, 48.85, 57.79)
    },
    ```

#### GitHub
- https://github.com/BryceCanyonCounty/bcc-guarma
