# FavoriteTeleport – GUI & UX Design

## Favorites Bar (fave_bar_GUI)
- Shows up to N favorite slots (default 10, configurable per-player) for the current surface.
- First slot is a red heart icon; toggles visibility of the rest of the bar.
- Each slot shows the favorite's icon (if set) and slot number.
- Left-click: teleport to favorite location.
- Right-click: open tag editor GUI for that favorite.
- Drag-and-drop: reorder favorites (except the heart slot).
- Tooltip: shows tag text, position, and description snippet.

## Tag Editor (tag_editor_GUI)
- Opens on right-click in map view or on a favorite slot.
- Allows editing tag text, icon, description, and position.
- Cancel/Confirm buttons; confirm validates and saves.
- Only one maptag per position.
- If editing another player's tag, only allow favoriting, not editing.

## Map View Operations
- Right-click in chart view: open tag editor at clicked position.
- Left-click on chart tag: open stock editor (mod listens for changes).
- Right-click on chart tag: open tag editor for that tag.

## General
- All GUIs must be rebuilt on relevant events (surface change, settings change, etc.).
- All user-facing strings must be localized (see `locale/en/`).
- All GUI state must be validated before update/destroy.

---

See also: `architecture.md`, `data_schema.md`, `error_handling.md`.
