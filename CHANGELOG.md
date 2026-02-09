# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure and documentation
- GitHub-ready files (README, LICENSE, .gitignore)
- Code quality improvements

## [1.0.0] - 2024-01-01

### Added
- Basic gear set management functionality
- Job-based organization system
- Export functionality for luashitacast profiles
- Augment support for gear items
- Level sync set handling
- Graphical user interface with ImGui
- Equipment grid and selection system
- Set creation, editing, and deletion
- Real-time gear preview

### Features
- Support for all Final Fantasy XI jobs
- Priority-based gear selection for level sync
- Augment parsing and formatting
- Direct export to luashitacast-compatible Lua code
- Two-tab interface (Sets and Rules)
- Command-line interface (`/lugear` or `/lg`)

### Technical
- Modular architecture with clear separation of concerns
- Type annotations using Lua annotations
- Event-driven architecture using Ashita framework
- Persistent settings storage
- Resource management integration with Ashita

## Future Plans

### Planned for 1.1.0
- Enhanced rule management system
- Advanced conditional logic for gear swapping
- Import functionality for existing luashitacast profiles
- Gear comparison and optimization tools
- Community gear set sharing

### Planned for 2.0.0
- Multi-profile support
- Advanced filtering and search capabilities
- Gear set templates and presets
- Performance optimizations
- Enhanced UI theming options

## [0.x.x] - Development Versions

### 0.9.0 - Pre-release
- Core functionality implemented
- Basic UI working
- Export system functional

### 0.5.0 - Early Development
- Project structure established
- Basic addon framework working
- Initial UI components created

---

**Note**: Version 1.0.0 represents the first stable release suitable for public use.