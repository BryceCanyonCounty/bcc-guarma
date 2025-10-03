# bcc-guarma

## Description

Escape to paradise with the **Guarma Travel Network**! This comprehensive travel system connects multiple ports across the map, allowing players to journey to the exotic island of Guarma and return to any connected destination. Whether you're seeking adventure or relaxation, the island awaits with pristine beaches and calm waters perfect for exploration with *bcc-boats*.

## Features

### 🚢 **Multi-Destination Travel System**

- **From Mainland**: Travel to Guarma from Saint Denis, Annesburg, and Blackwater
- **From Guarma**: Interactive menu system to travel back to any connected port
- **Expandable**: Easy configuration to add new travel destinations

### 🎫 **Advanced Ticketing System**

- Boat tickets available at all ports with inventory management
- Flexible pricing: Cash, Gold, or Item-based payments
- **New**: Item consumption control - items can be consumed or just checked (membership cards)
- Tickets stack up to 4 per player (perfect for gifts)
- Immediate use or save for later travel

### 🏪 **Smart Port Management**

- Individual port hours with open/closed status
- Distance-based NPC spawning for performance
- Job-restricted access with grade requirements
- Colored blips reflecting port status (open/closed/job-locked)

### 🎮 **Enhanced User Experience**

- **FeatherMenu Integration**: Beautiful, intuitive travel selection from Guarma
- Browse destinations without requiring tickets upfront
- Real-time travel time display with proper formatting
- Seamless ticket validation only when travel begins

### 🔧 **Configuration & Security**

- Separated configuration structure (Shops vs Guarma)
- Comprehensive input validation and security measures
- Performance optimizations with pre-calculated data
- Multi-language support (English, German, French, Romanian)

## Dependencies

- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)
- [feather-menu](https://github.com/FeatherFramework/feather-menu)

## Installation

1. **Install Dependencies**: Ensure all dependencies are installed and updated
2. **Add Resource**: Place `bcc-guarma` folder in your resources directory
3. **Resource Configuration**: Add `ensure bcc-guarma` to your `server.cfg` or `resources.cfg`
4. **Database Setup**: **Automatic** - The system will seed items on first start
5. **Inventory Images**: Add `boat_ticket.png` to `vorp_inventory/html/img/`
6. **Restart Server**: Complete installation with a server restart

### Database System

The resource features a **modern automatic database system**:

- **Item Seeding**: Required items (boat tickets) are automatically added to your items table
- **Version Control**: Database schema versioning prevents conflicts
- **Multi-Database Support**: Compatible with both MySQL and MariaDB via oxmysql
- **No Manual SQL**: No need to manually import SQL files

#### Database Commands

For troubleshooting, the following server console commands are available:

- `bcc-guarma:seed` - Manually re-seed all items into the database
- `bcc-guarma:verify` - Check if all required items exist in the items table

*Note: These commands can only be run from the server console, not in-game.*

## Advanced Configuration

### Adding New Destinations

To add a new port that travels to Guarma:

1. Add shop configuration to `configs/shops.lua`
2. Set `travel.location = 'guarma'`
3. Configure pricing, NPCs, and blips as needed
4. The destination will automatically appear in Guarma's travel menu

## Tips & Recommendations

### Guarma Respawn Point

Add a respawn point for Guarma in your `vorp_core` config:

```lua
Guarma = {
    name = "Guarma",
    pos = vector4(1309.37, -6895.1, 48.85, 57.79)
},
```

### Performance Optimization

- NPC spawning is distance-based for optimal performance
- Blip management automatically handles visibility
- Pre-calculated ticket costs reduce server load

### Pricing Strategy

- Use different currencies for varied gameplay (cash/gold/items)
- Set `remove = false` for VIP/membership systems
- Consider travel time when setting prices

## GitHub

- [bcc-guarma](https://github.com/BryceCanyonCounty/bcc-guarma)
