# LuGear

A helper addon for Ashita to make creating luashitacast profiles easier.

## Overview

LuGear is a graphical interface addon that simplifies the process of creating and managing gear sets for luashitacast profiles. It provides an intuitive UI for organizing gear sets by job, managing augments, and exporting configurations directly to luashitacast-compatible format.

## Features

- **Job-based Organization**: Organize gear sets by Final Fantasy XI job
- **Gear Set Management**: Create, edit, and delete gear sets with ease
- **Augment Support**: Full support for gear augments and modifications
- **Level Sync Sets**: Special handling for level-synced gear priority lists
- **Export Functionality**: Direct export to luashitacast-compatible Lua code
- **Real-time Preview**: See your gear configurations before exporting

## Installation

1. Download the LuGear addon files
2. Place the `LuGear` folder in your Ashita addons directory
3. Add the following to your `boot.lua` or load manually:
   ```lua
   ashita.load('LuGear')
   ```

## Usage

### Basic Commands
- `/lugear` or `/lg` - Toggle the LuGear interface

### Interface Overview
The LuGear interface consists of two main tabs:

#### Sets Tab
- **Job Selection**: Choose the job you're configuring gear for
- **Set Management**: Create, edit, and delete gear sets
- **Gear Grid**: Visual representation of your current gear set
- **Equipment Browser**: Browse and select gear for each slot

#### Rules Tab
- Configure advanced rules and conditions for gear swapping
- Set up conditional logic for different combat scenarios

### Creating a New Set
1. Select your desired job from the dropdown
2. Click "New Set" to create a new gear set
3. Name your set and choose whether it should be level-synced
4. Use the gear grid and equipment browser to populate slots
5. Export your configuration when complete

## File Structure

```
LuGear/
├── Components/          # UI component modules
│   ├── EquipmentGrid.lua    # Main gear display grid
│   ├── GearSelection.lua    # Equipment selection interface
│   └── Header.lua           # Top-level UI controls
├── Constants.lua        # Type definitions and job constants
├── Modules/             # Utility modules
│   ├── Event.lua            # Event handling utilities
│   ├── GetAugments.lua      # Augment parsing and management
│   └── Theme.lua            # UI theming and styling
├── State.lua           # Application state management
├── Systems/            # Core system modules
│   ├── DataManager.lua      # Data persistence
│   ├── DebugManager.lua     # Debugging utilities
│   ├── Exporter.lua         # Luashitacast export functionality
│   ├── FilterGear.lua       # Gear filtering and search
│   ├── JobManager.lua       # Job-specific logic
│   ├── RuleManager.lua      # Rule management system
│   └── SetManager.lua       # Gear set management
├── UIs/                # Main UI modules
│   ├── RulesUI/
│   │   └── Rules.lua        # Rules tab interface
│   └── SetsUI/
│       └── Sets.lua         # Sets tab interface
├── lugear.lua          # Main addon entry point
└── State.lua           # Application state
```

## Dependencies

- **Ashita Framework** - Required for addon functionality
- **ImGui** - For the graphical user interface
- **Final Fantasy XI** - Game client with Ashita support

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Check the [Issues](../../issues) section
- Join the Ashita community forums
- Review the luashitacast documentation

## Changelog

### v1.0
- Initial release
- Basic gear set management
- Export functionality
- Job-based organization
- Augment support

## Acknowledgments

- The Ashita development team for creating an excellent addon framework
- The luashitacast community for inspiration and feedback
- Final Fantasy XI for being an amazing game

---

**Note**: This addon is not affiliated with Square Enix or the official Final Fantasy XI development team.