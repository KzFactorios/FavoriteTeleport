# FavoriteTeleport – Coding Standards

## General
- Use LuaCATS/EmmyLua-style annotations for all public functions, types, and module exports.
- Use explicit, descriptive names for all variables and functions. Avoid ambiguous or legacy names.
- All helpers and accessors must require `surface_index` and `player_index` where relevant.
- No direct requires between GUI modules; use event/message passing if needed.
- Keep file sizes small; split into logical modules as needed.
- Remove all references to `TODO - implement` or similar unenforced conventions.
- Use `ft_` prefix only if necessary to avoid naming collisions.

## Documentation
- All modules must have a top-level docstring describing their purpose and usage.
- All public functions must be documented with parameter and return types.
- Document all known limitations and edge cases.

## Debugging & Logging
- Use conditional debug logging via `context.__DEBUG__`.
- All errors must be logged to `factorio-current.log`.
- All user-facing messages must be localized and sent via the chat log.

## Error Handling
- Always check `.valid` on Factorio objects before use.
- Remove invalid tags from collections.
- Handle all edge cases (e.g., uncharted chunks, missing data) gracefully.

## Multiplayer & Surface Safety
- Never share mutable state between players except for shared caches (e.g., map tags).
- All persistent data must be surface-aware and player-scoped where appropriate.

---

See also: `architecture.md`, `data_schema.md`, `error_handling.md`.

### Misc
- Always put require statements at the top of the file
- Use dot notation for require statement paths
- Use targeted diagnostic suppressors over global. global is ok but definitely not the oreferred option
- If there isn't a viable suppression available, leave a comment explaining the type checker limitation and why the code is safe for runtime/test
- Always be on the lookout for recursive requires. Ensure we are looking out for too many c levels error
- keep the codebase maintainable and bug-free. read through the code and propose tasks that would help to achieve this goal.

# Image/Sprite Usage
- Always verify the existence and path of any image or sprite before including it in code. Use only built-in utility sprites or styles (e.g., `red_slot_button`) for backgrounds and buttons unless a custom image is required.
- Do not reference deprecated or moved files (e.g., `__core__/graphics/utility/slot.png` or `__core__/graphics/utility/gui.png`) without confirming their presence in the current Factorio version.
- Prefer using built-in style inheritance (such as `parent = "red_slot_button"`) for destructive buttons, as this is robust and future-proof.
- If a file-not-found error occurs, check the latest Factorio asset locations and update the code to use the correct built-in style or sprite.

# Button Style Guidelines
- When using custom images for button styles, ensure the `position` property is not included in the `graphical_set` definitions. The `position` property is only valid for sprite sheets, not standalone PNGs.
- Use tinting to differentiate button states (e.g., hover, click, disabled) for better visual feedback. For example:
  - Default: `{ r = 0.8, g = 0.8, b = 0.8, a = 1 }`
  - Hovered: `{ r = 0.9, g = 0.9, b = 0.9, a = 1 }`
  - Clicked: `{ r = 0.7, g = 0.7, b = 0.7, a = 1 }`
  - Disabled: `{ r = 0.6, g = 0.6, b = 0.6, a = 1 }`
- Always verify the existence of image files (e.g., `graphics/white_slot_button_20.png`) and ensure they are correctly referenced in the mod folder structure.

# Historical Note
- In May 2025, we resolved repeated mod loading errors by switching from direct image references to using built-in style inheritance (e.g., `parent = "red_slot_button"`). This is the preferred method for Factorio v2 and later.

## Localization Placeholders
- When using Factorio locale placeholders, use double underscores (e.g., `__1__`) for variable substitution, not curly braces or brackets.
- Example:
  - In your locale file: `ft_tag_editor_teleport_tooltip=Teleport to __1__`
  - In Lua: `{ "ft_tag_editor_teleport_tooltip", value }`

This ensures correct variable substitution in all user-facing strings.

Only require modules once at the top of the file.
Use the already-imported variables (e.g., Helpers, Storage) inside your functions.