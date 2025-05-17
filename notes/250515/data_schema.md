# FavoriteTeleport – Data Schema

## Overview
Defines the persistent data structures for the mod, including player favorites, map tags, and settings. All data is managed via the `context` module and is surface-aware.

---

## Top-Level Schema

```lua
storage = {
  mod_version = "0.0.01",
  players = {
    [player_index] = {
      show_fave_bar_buttons = boolean,
      render_mode = string,
      -- ...other per-player data
      surfaces = {
        [surface_index] = {
          favorites = {
            [slot_number] = {
              slot_locked = boolean,
              favorite = {
                gps = string,
                slot_locked = boolean 
                -- ...other favorite fields
              }
            },
          },
          -- ...other per-surface player data
        }
      },
    },
  },
  surfaces = {
    [surface_index] = {
      maptags = {
        [tag_id] = {
          tag = LuaCustomChartTag,
          gps = string,
          faved_by_players = { [player_index] = true },
          description = string,
          -- ...other tag fields
        },
      },
      -- ...other per-surface data
    },
  },
  -- ...other global mod data
}
```

---

## Player Favorites
- Each player has a `favorites` table for each surface.
- Each favorite is keyed by slot number and contains a `favorite` object and a `slot_locked` flag.

## Map Tags
- Cached per-surface in `surfaces[surface_index].maptags`.
- Each tag tracks which players have favorited it via `faved_by_players`.

## Settings
- Per-player settings (e.g., `show_fave_bar_buttons`, `render_mode`) are stored at the player level.
- Mod-wide settings (e.g., `mod_version`) are stored at the root.

---

## Notes
- All helpers and accessors must be surface-aware.
- No legacy/ambiguous fields (e.g., `qmtt`, `qmt`).
- See also: `architecture.md`, `coding_standards.md`.
