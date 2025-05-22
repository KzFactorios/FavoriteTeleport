# FavoriteTeleport – Architecture

## Overview
This document describes the architecture of the FavoriteTeleport mod, including its modular structure, data flow, and key design patterns. It is intended to help developers understand how the mod is organized and how its components interact.

---

## High-Level Structure
- **Persistent Data:** All persistent data is stored in `global.FavoriteTeleport` and managed via the `core/cache` module.
- **Core Modules:** Handle tag/favorite logic, context, and multiplayer safety.
- **GUI Modules:** Provide user interfaces for managing favorites, tags, and settings.
- **Tag Sync:** Ensures tag/favorite consistency across multiplayer and surfaces.
- **Lifecycle & Events:** Manage mod initialization, configuration changes, and event registration.

---

## Module Breakdown
- `core/cache/` – Persistent data cache, schema, init methods and helpers.
- `core/favorite.lua` – Favorite object logic and helpers.
- `core/map_tag.lua` – Map tag object logic and helpers.
- `core/context.lua` – (Legacy) Context abstraction for persistent data.
- `core/tag_sync/` – Tag synchronization and migration logic.
- `core/control/` – Lifecycle, event, and utility modules.
- `gui/` – GUI modules for favorite bar, tag editor, and cache viewer.

---

## Data Flow
1. **Player Action:** Player interacts with the GUI or map.
2. **GUI/Event Handler:** Calls into core logic (e.g., add favorite, move tag).
3. **Core Logic:** Updates persistent data in `global.FavoriteTeleport` via `Cache`.
4. **Tag Sync:** Ensures multiplayer and surface consistency.
5. **GUI Update:** Observers update the GUI to reflect changes.

---

## Key Patterns
- **Surface Awareness:** All helpers and accessors are surface-aware.
- **Observer Pattern:** Used for GUI updates and event notification.
- **Modularization:** Each concern (cache, GUI, tag sync, etc.) is in its own module.
- **Testability:** All logic is testable and covered by automated tests.

---

## See Also
- `design_specs.md` – Project goals and feature overview.
- `data_schema.md` – Persistent data schema and structure.
- `coding_standards.md` – Coding conventions and best practices.
