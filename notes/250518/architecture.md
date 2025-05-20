# FavoriteTeleport – Architecture & Data Flow

## Module Responsibilities

- **control.lua**: Main entry point. Registers events, manages lifecycle, and coordinates between modules.
- **core/context.lua**: Persistent data storage and schema management. Provides safe, surface-aware access to player and mod data.
- **core/favorite.lua**: Favorite location logic and data structures.
- **core/storage/**: Storage helpers, slot management, and migration utilities (modularized).
- **core/utils/helpers/**: Utility functions, type checks, and surface-aware helpers (modularized).
- **gui/fave_bar_GUI.lua**: Favorites bar GUI logic, slot interaction, and drag-and-drop.
- **gui/tag_editor_GUI.lua**: Tag editor GUI for adding/editing map tags, with submodules for actions, favorite ops, and chart tag ops.
- **core/map_tag.lua**: Extended map tag logic, caching, and validation.
- **settings.lua**: Per-player runtime settings and accessors.
- **constants.lua**: Mod constants and enums.
- **migrations/**: Version migration scripts and legacy data handling.

## Data Flow
- All persistent data is stored in the `global.FavoriteTeleport` table, with per-player and per-surface isolation.
- GUI actions update storage via modular helpers, which immediately persist and update the UI.
- Events and hotkeys are registered centrally and dispatched to the appropriate module.

## Extensibility & Testing
- All major features are split into submodules for maintainability.
- Test suite covers storage, GUI, and helpers.
- New features can be added by creating new submodules and updating the main entry points.
