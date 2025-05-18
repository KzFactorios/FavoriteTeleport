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