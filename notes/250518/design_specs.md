# FavoriteTeleport – Design Specs

## Overview
FavoriteTeleport is a Factorio mod that provides a robust, modular, and user-friendly system for managing, teleporting to, and annotating favorite locations on the map. The mod features a modern, dynamic GUI, per-player settings, and a maintainable, testable codebase.

## Key Features
- **Favorites Bar (fave_bar_GUI):**
  - Up to N favorite slots (default 10, configurable per-player).
  - Modern, responsive, and idiomatic Factorio GUI.
  - Drag-and-drop slot reordering (with locked slot support).
  - Left-click to teleport, right-click to open tag editor.
  - Tooltips show position and tag text.
  - Per-player toggle for bar visibility and hotkey enable/disable.
- **Tag Editor GUI:**
  - Opens on right-click in map view or on a favorite slot.
  - Edit tag text, icon, description, and position.
  - Cancel/Confirm buttons; confirm validates and saves.
  - Only one maptag per position.
  - If editing another player's tag, only allow favoriting, not editing.
- **Cache & Data Layer:**
  - Modularized cache for player favorites, chart tags, and events.
  - Robust migration and schema management.
  - Per-player and per-surface data isolation.
- **Hotkeys & Events:**
  - Table-driven or loop-based registration for hotkeys.
  - Central handler for teleport and tag editor events.
- **Testing & Maintainability:**
  - Modular code structure for all major features.
  - Comprehensive test suite for cache, GUI, and helpers.
  - Clear separation of GUI, cache, and logic layers.

## Architecture
- **control.lua:** Main entry point, event registration, and lifecycle management.
- **core/context.lua:** Persistent data cache and schema management.
- **core/cache/**: Modular cache helpers and migration utilities.
- **core/utils/helpers/**: Utility functions, type checks, and formatting.
- **gui/fave_bar_GUI.lua:** Favorites bar GUI logic and slot interaction.
- **gui/tag_editor_GUI.lua:** Tag editor GUI and submodules for actions, favorite ops, and chart tag ops.
- **settings.lua:** Per-player runtime settings and accessors.
- **constants.lua:** Mod constants and enums.

## UI/UX Design
- Modern, visually appealing, and responsive GUI.
- Adapts to UI scale and screen size.
- Uses Factorio styling and idioms.
- Tooltips, error handling, and chat messages for user feedback.

## Edge Cases & Robustness
- Handles nil values, type safety, and missing data.
- Locked slots cannot be reordered or overwritten.
- Drag-and-drop persists immediately and updates UI.
- All GUI actions are safe and error-tolerant.

## Extensibility
- Modular structure allows for easy addition of new features.
- Shared helpers and submodules for code reuse.
- Clear separation of concerns for maintainability.

---

See also: `architecture.md`, `fave_bar_GUI.md`, `gui_ux.md` in this folder for more details.
