# Omissions and Open Questions After Spec Review

## Glaring Omissions

1. **Unit Test Details**
   - No guidance on which modules/functions to prioritize for testing or required coverage.
   - No mention of test file naming conventions or structure.
   - this aspect is currently on hold

2. **Localization Implementation**
   - Locale file structure and naming conventions are not specified.
   `locale/en`
   - No details on how/when to load and use localized strings in GUIs or messages.
   - this part will be implemented later

3. **GUI Desync Handling**
   - No requirements for detection, recovery, or user notification in case of GUI desyncs.
   - No strategies for auto-recovery or user prompts.
   - I will need the chat agent to suggest ideas at a later date

4. **Performance/Caching Strategy**
   - No cache invalidation strategies or refresh/clear cache details.
   the surface.chart_tags collection will be refreshed whenever a player adds a new map_tag. This will involve deleting the collection and rebuilding in a getter function
   - No memory usage considerations for large multiplayer games.
   - We will address this issue later on

5. **Migration Handling**
   - No outline for future migration structure or triggers.
   - No plan for handling breaking changes in persistent data.
   - this will be discussed at another time

6. **Error Handling**
   - No specifics on error surfacing (levels, formatting).
   - No details on error logging location/format beyond factorio-current.log.
   - this will be discussed at another time

7. **Mod Conflict Detection**
   - No process for detecting or handling mod conflicts.
   - No guidance on warning users or disabling features in case of conflict.
   - this will be discussed at another time

8. **Security/Abuse Prevention**
   - No mention of preventing abuse (e.g., teleport spam, unauthorized tag edits).
   - this will be discussed at another time

9. **Data Validation**
   - No details on what constitutes a valid/invalid tag beyond chunk charting.
   - actually chart_tags have their own `valid` field
   - No sanitization or recovery plan for invalid data.
   - will be addressed as we progress

10. **Hotkey Customization**
    - No mention of allowing users to customize hotkeys.
    - This is a feature that we will tackle later

---

## Questions for Clarification

1. Should unit tests cover only core logic, or also GUI/event handling? Should mocks/stubs be used for Factorio API calls?
- ignore for now
2. Should all user-facing strings be localized from the start, or only as needed? What is the preferred locale file format?
- we should do this from the start
preferred folder is `locale\en`
3. Should the mod attempt to auto-recover from GUI desyncs, or just notify the user? Are there known desync scenarios to handle?
- I am not even sure what a GUI desync is, so I will need the agent to suggest solutions
4. If a user reduces their slot count and has more favorites than the new limit, should the user be prompted to choose which to keep, or should the oldest/last slots be removed automatically?
- for now, the user will be limited to the default # of slots - 10
5. Should the mod version in storage be updated automatically on every change, or only on migrations?
I will handle the versioning myself
6. Are there specific mods known to conflict, or should the mod check for any mods that modify chart tags/teleportation?
- not at this time
7. Should there be any admin-only features, or is everything per-player?
admins-only settings: Favorites Bar On, Slots, teleport radius 
8. Is there a maximum expected number of players/surfaces/tags to optimize for?
I don't see why there should be any limits
9. Should errors be output only to the chat log, or also to a file or debug console?
let's log errors to a file called error-log.txt in the notes directory
10. If settings are changed (e.g., slot count), should there be a backup of old data?
no

---

*Please review and clarify these points to ensure a robust implementation.*

## use the following as an addendum to programming concepts and direction
Next Steps / Suggestions
GUI Desync Handling

Since you requested suggestions: In Factorio, GUI desyncs can occur if the GUI state on the client and server diverge (e.g., due to missed events or script errors). To mitigate:
Always use event-driven updates for GUIs.
Validate GUI state on every relevant event (e.g., on_tick, on_gui_click).
If a desync is detected (e.g., missing/extra elements), destroy and rebuild the GUI for the affected player.
Log desync events to error-log.txt and notify the user via chat.
Provide a “Reset GUI” button for users to manually recover.
Would you like a sample implementation plan for this?
Admin-Only Settings

You specified some settings as admin-only. Ensure there’s a check for admin status before allowing changes to these settings.
Error Logging

You want errors logged to error-log.txt. Make sure to implement a utility function for this, and use it consistently across modules.
Localization

Since you want localization from the start, ensure all user-facing strings are wrapped in a localization function, and that locale files are created as you go.
No Backup on Settings Change

Since you don’t want backups, be sure to warn users if data loss is possible when changing settings.
