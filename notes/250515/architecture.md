# FavoriteTeleport – Architecture & Data Flow

## Overview
This document describes the high-level architecture, module responsibilities, and data flow for the FavoriteTeleport Factorio mod. It is designed for maintainability, extensibility, and robust multiplayer support.

---

## Module Responsibilities

- **control.lua**: Main entry point. Registers events, manages lifecycle, and coordinates between modules.
- **core/context.lua**: Persistent data storage and schema management. Provides safe, surface-aware access to player and mod data.
- **core/favorite.lua**: Favorite location logic and data structures.
- **core/storage.lua**: Storage helpers, slot management, and migration utilities.
- **core/utils/helpers.lua**: Utility functions, type checks, and surface-aware helpers.
- **gui/fave_bar_GUI.lua**: Favorites bar GUI logic, slot interaction, and drag-and-drop.
- **gui/tag_editor_GUI.lua**: Tag editor GUI for adding/editing map tags.
- **core/map_tag.lua**: Extended map tag logic, caching, and validation.
- **settings.lua**: Per-player runtime settings and accessors.
- **constants.lua**: Mod constants and enums.
- **migrations/**: Version migration scripts and legacy data handling.

---

## Data Flow

- All persistent data is managed via the `context` module.
- Player favorites are stored per-surface, per-player.
- Map tags are cached per-surface and shared among all players.
- GUIs are rebuilt on relevant events (surface change, settings change, etc.).
- All user actions and game events are handled via Factorio’s event system.

---

## Event Handling

- Centralized in `control.lua`.
- Custom input and GUI events are dispatched to dedicated modules.
- Player join/leave/configuration events trigger data and GUI re-initialization.

---

## Multiplayer & Surface Safety

- All helpers and accessors require explicit `surface_index` and `player_index`.
- No global state is shared between players except for map tag caches.
- All GUIs and data are rebuilt or validated on migration/configuration change.

---

## Extensibility

- New features should be implemented in new modules or submodules.
- Avoid direct requires between GUI modules to prevent circular dependencies.
- Use LuaCATS/EmmyLua-style annotations for all public functions and types.

---

See also: `data_schema.md`, `coding_standards.md`, `gui_ux.md`, `error_handling.md`.
