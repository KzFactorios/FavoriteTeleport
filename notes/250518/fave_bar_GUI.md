# Favorite Bar GUI (fbg) – Design Spec

## Behavior and Settings
- The favorites bar (fbg) is an interface for managing player favorites.
- Per-player toggle for bar visibility (`favorites-on` setting).
- Hotkey enable/disable and UI scale responsiveness.

## Hotkey/Event Registration
- Use a table-driven or loop-based registration for hotkeys (e.g., `Constants.events.TELEPORT_TO_FAVORITE .. i`).
- Central handler checks settings and slot validity before teleporting.

## Favorite Bar UI Structure
- Outer frame contains two horizontal frames:
  1. `toggle_favorite_buttons` (shows/hides the bar, syncs with cache).
  2. Up to `MAX_FAVORITE_SLOTS` buttons for player favorites, in order.
- If fewer favorites than slots, fill with `{ gps = "", slot_locked = false }`.
- If more than `MAX_FAVORITE_SLOTS`, throw an error.
- Always initialize missing values/structures.

## Favorite Slot Management
- Each favorite shows its icon and a caption with the slot number.
- Tooltip: First line is the gps (x/y only), second line is the tag's text (if present).
- Left-click: Teleport to location (with error handling and chat message).
- Right-click: Open tag editor for that favorite.
- Drag-and-drop: Reorder favorites, persist immediately. Locked slots cannot be reordered or overwritten.

## Styling and Responsiveness
- Modern, dynamic, and visually appealing (Factorio idioms).
- Adapts to screen size and UI scale.
- Uses animations or clever styling for appeal.

## Data Layer and Edge Cases
- Robust handling of nil values, type safety, and missing data.
- All GUI actions are safe and error-tolerant.
- Locked slots and drag-and-drop edge cases are handled.
