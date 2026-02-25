# LuGear

A addon for Ashita to make creating luashitacast profiles easier.

## Version

Made currently for Ashita v4.16

## Features

- **Job-based Organization**: Organize gear sets by job
- **Gear Set Management**: Create, edit, and delete gear sets
- **Level Sync Sets**: Support for level-synced gear sets
- **Export Functionality**: Direct export to luashitacast-compatible Lua code
- **Real-time Preview**: See your gear configurations before exporting

## Installation

1. **Download**: Grab the latest release from the [Releases Page](https://github.com/InnLumin/LuGear/releases/latest).
2. **Extract**: Unzip the `LuGear.zip` file. You should be left with a folder named `LuGear`.
3. **Move**: Place the `LuGear` folder into your Ashita `addons` directory.
   
   > Ensure your directory structure looks like this:
   > `Ashita/addons/LuGear/lugear.lua`
   > (If you see `Ashita/addons/LuGear/LuGear/lugear.lua`, the addon will not load)

## Usage

### Basic Commands
* `/lugear` or `/lg` - Toggle the interface

### Creating a New Set
1. Select your desired job from the dropdown
2. Click "New Set" to create a new gear set
3. Name your set and choose whether it should be level-synced
4. Use the gear grid and equipment browser to populate slots
5. Export your configuration when complete