<!-- filepath: v:\Fac2orios\2_Gemini\mods\FavoriteTeleport\notes\250515\fave_bar_GUI.md -->
the fave_bar_GUI - fbg

the fbg is essentially an interface for managing player favorites.

## Behavior and Settings

- There is a runtime, per-player setting to hide the entire fbg: `mod_settings["favorites-on"]`.
  - When this value is **false**, the fave bar will not be shown/opened and should be closed at the soonest opportunity. Favorites are effectively cancelled. Shortcut keys ctrl+(0-9) should be disabled. Player data does not have to be changed and teleporting and tag-editor are still functional, except the is_favorite row in the tag_editor, which should be hidden when favorites-on = false.
  - When this value is **true** (default), the entire fbg should be shown.
  - The setting is per-player and should be read on player join and on setting change events.
  - The shortcut keys should be editable in the game settings (Controls menu).
  - If toggled to false, the bar should be hidden immediately and hotkeys disabled.

## Hotkey/Event Registration

- Suggest an elegant design pattern to handle multiple definitions for almost the same event registration for the hotkeys in `control.lua`: `Constants.events.TELEPORT_TO_FAVORITE .. i`.
- Consider a table-driven or loop-based registration, and a central handler that checks the setting and slot validity before teleporting.

## Favorite Bar UI Structure

- The fbg has an outer frame. Within that frame are two horizontal frames:
  1. The first holds a single button, `toggle_favorite_buttons`, that toggles the display of the second frame. This button syncs with `storage.players[player_index].toggle_fave_bar_buttons` (default = true). Always initialize any missing values/structures if necessary.
  2. The second frame shows `MAX_FAVORITE_SLOTS` buttons, one for each player favorite, in the order specified by its index.
    - If the number of player favorites is less than `MAX_FAVORITE_SLOTS`, fill with:
      ```lua
      { gps = "", slot_locked = false }
      ```
    - If a player has more than `MAX_FAVORITE_SLOTS`, throw an error.
    - If a player has no favorites, their collection should be filled with `MAX_FAVORITE_SLOTS` initialized as above.

## Favorite Slot Management

- The buttons manage favorite slots and coordinate with the data layer.
- Each favorite shows its icon and a caption with the slot number.
- Tooltip: First line is the gps (x/y only, format `xxx.yyy`). Second line is the chart_tag's text value (if present and non-empty; otherwise, omit the second line).
- Left-click: Teleport the player to the selected location. If teleporting fails, show a message in the chat log.
- Right-click: Always open the tag_editor, using the gps of the favorite as the source for the tag_editor's current position.
- Drag and drop: Maintains the order of favorites in storage and in the fbg. Reordering persists immediately. Slots with `slot_locked = true` cannot be reordered or lose their slot during a reorder.

## Styling and Responsiveness

- The bar should be modern, dynamic, and visually appealing, following idiomatic Factorio design.
- The bar must adapt to different screen sizes and UI scales.
- Use animations or clever styling to enhance appeal.

## Data Layer and Edge Cases

- All changes (add, remove, reorder, edit) are immediately reflected in storage. Use safe fallbacks if data is corrupt or missing.
- Data schema migration/upgrade is deferred for now.

---

*This document reflects the clarified requirements and design decisions as of May 18, 2025.*

