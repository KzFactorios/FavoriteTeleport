# FavoriteTeleport – Error Handling & Edge Cases

## General Principles
- All errors must be logged to `factorio-current.log`.
- All user-facing error messages must be localized and sent via the chat log.
- Always check `.valid` on Factorio objects before use.
- Remove invalid tags from all collections.

## Chart Tag Validation
- Only add chart tags to charted chunks (check with scripting API; add_chart_tag returns nil if invalid).
- Always check `.valid` before manipulating tag objects.
- If a chunk becomes uncharted, tags may persist but not be visible.

## Teleportation
- If teleportation fails, output the reason to the chat log.
- Use a configurable teleport radius to find a valid position if the target is occupied.

## GUI Desyncs
- Rebuild GUIs on player join, surface change, or configuration change.
- Validate all GUI state before updating or destroying elements.
- Use event-driven updates to keep GUIs in sync with data.
- If a desync is detected, destroy and rebuild the affected GUI.

## Multiplayer Edge Cases
- All player data must be surface-aware and player-scoped.
- Never allow one player to edit another's favorites; map tags are shared but favorites are not.

---

See also: `coding_standards.md`, `architecture.md`, `gui_ux.md`.
