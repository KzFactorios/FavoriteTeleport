# Favorite Teleport Mod – Spec Sheet

## Overview
A Factorio mod that enhances map tag management and teleportation, providing a favorites bar, quick map tag editing, and custom GUI elements. The mod is designed for multiplayer and singleplayer, with robust event handling and persistent player data.

---

## Key Features
- **Quick Teleportation:** Hotkeys to teleport to favorite map tag locations. Ctrl + [number] (1,2,3,4,5,6,7,8,9,0). 0 acts as 10. 

- **favorites_GUI:** Custom GUI for managing and selecting favorite locations. The player can have 10 favorite locations/slots per surface. It would be a plus for the max number of slots to be handled dynamically in the user settings. The favorites bar will only ever show the favorites for the current surface. The favorites bar shows the slots, horizontally in the top gui, with small icons, if defined, for each favorite on the surface. There is an additional first slot with the icon of a red heart. This red heart icon will toggle the display of the remaining buttons and is tied to the user_data[show_fave_bar_buttons] It also shows the slot number for easy navigation (ie corresponds to the hotkey number for the slot). A left click on the slot immediately teleports the player to the favorites location. A right click on a slot will open a dialog, fave_editor_GUI in the gui.screen. Icons for each fave are to be shown in each slot. each slot should be 32px x 32px

- **fave_editor_GUI:** Custom GUI for adding, editing, and removing map tags. Should show the current icon for the tag as 50px x 50px in a picker where another icon can be selected with ease

- **Uses the existing map tag editor** Not all functionality can be implemented in our custom guis. 

- **Persistent Data:** Player favorites and settings are stored using a context-based schema. See below for further explanation of the structure

- **Custom Input Events:** Hotkeys and custom input events for fast actions.

- **Multiplayer considerations are imperative!** individual player settings should not apply to all players. Each player can have their own preferences for showing the fave bar gui and using the favorites at all. Each player's favorites are their own. Other players should be able to see anotther players tags, but as far as favorites go, they are per-player and not shared with other players. 
---

## Core Modules

### 1. `control.lua`
- Main entry point for event registration and mod lifecycle.
- Handles Factorio events: player join/leave, configuration changes, runtime settings, tick events, and custom input.
- Initializes and updates GUIs for all players.

### 2. GUI Modules
- **`fave_bar_GUI.lua`**: Handles displaying the current favorites for the current surface. Handles events triggered by slot interaction - right-click, left-click. Implement drag and drop within the favorites bar to order and reorder favorites

- **`tag_editor_GUI.lua`**: Manages a GUI to add and update map tags.

### 3. `context.lua`
- **Persistent data storage and schema management.**
- Replaces legacy `storage` module.
- Provides player data access, inits all data structures

### 5. 
- Handles custom input events (hotkeys, GUI triggers).

### 7. `constants.lua` 
- Defines mod constants
### 6. settings.lua
per-player settings and access to player settings

### 8. ext_tag.lua
- class for handling extended details related to a chart_tag

### 9. the "migrations" folder
- stores any migrations for version changes
- stores old settings and player_data prior to the migration to aid in rebuilding after an unseen error
---

## Data Flow & Architecture

- **Event-Driven:** All user actions and game events are handled via Factorio’s event system, with custom events for mod-specific actions.

- **Persistent Context:** All player and mod data is stored in a context object, ensuring safe migration and multiplayer compatibility.

---

## Storage Structure (Persistent Data)

- **All persistent data is managed via the `context` module.**
- The storage schema is player-centric and surface-aware, supporting multiplayer and multiple surfaces.

- **Typical structure:**
This is just my first stab at structure. If you see a better way, please feel free to chime in.

  ```lua
  storage = {
    mod_version = 0.0.01,
    
    players = {
      [player_index] = {
          [surface_index] = {
            favorites = {
              [slot_number] = {
                slot_locked: boolean,
                favorite = {
                  pos_string: string,
                }
              },
            }
            ...
          },
          ...
        
        show_fave_bar_buttons = true/false,
        render_mode = player.render_mode
        },
      },
    
    surfaces = {
        [surface_index] = {
          maptags = {
            -- ext_tag objects are to be cached for the surface
              -- these are shared by all players
              tag, -- LuaCustomChartTag
                pos_string,
                faved_by_players {
                  list of player indices that have favorited this position
                },
                text
                description,
              }
          }
        }
      }
      ...
    },
    ... -- other global mod data
  }
  ```

a players' favorites are scoped to the current player's surface only


---

## Initialization & Lifecycle

- **`on_init`:** Initializes context, GUI structures, registers GUI handlers, and sets up all player GUIs.

- **`on_load`:** 
- **`on_configuration_changed`:** Handles mod upgrades, migration, and player re-initialization.
- **Player Events:** Handles player join, leave, and removal, cleaning up GUIs and data as needed.

---

## Coding Patterns & Best Practices

- **No Direct Requires Between GUI Modules:** structure the code to prevent circular dependencies.
- **Event Handler Centralization:** All custom input and GUI events are handled in dedicated modules.
- **Debug Logging:** Conditional debug logging using `context.__DEBUG__`.
- Always use best-practices
- try to keep files sizes as small as possible even if it means creating other files for better organization and readability
- remove any references to qmtt or qmt. It will be preferred to prepend "ftt_" to variables or functions ONLY IF NECESSARY

- Annotate code using the LuaCATS/EmmyLua-style comments
- ensure Lua Language Server extension from the VS Code is installed
- problems should be addressed asap in the design/coding lifecycle

---

## Known Limitations / Gotchas

- **No Code After Return:** Lua ignores code after a `return` statement.

---

## Error Handling & Edge Cases
invalid tags should be removed from any chart_tags collections.

Key Validation Rules for Chart Tags
Chunk Must Be Charted:
A chart tag can only be added to a location if the chunk at that position is already charted (i.e., revealed on the map) for the relevant force (player or team). Attempting to place a chart tag on an uncharted chunk will fail, and the API will return nil.

API Behavior:
When using the scripting API (e.g., LuaForce.add_chart_tag), the function will return the new tag if successful, or nil if the position is invalid for a chart tag-most commonly because the chunk is not charted.

Persistence:
Chart tags are stored per force and per chunk. If a chunk becomes uncharted (e.g., due to fog of war), the tag may not be visible but can persist in the data structure.

Object Validity:
When manipulating chart tags via scripting, always check the .valid property of the tag object to ensure it still exists and is accessible, especially after changes to the game state.


Please suggest methods to handle GUI desyncs

All communication to the user should be handled via console/chat-log output

- create a folder for tests. **don't worry about any other testing details at this point.**

log all mod errors to the factorio-current.log



## Other considerations
- lookout for any mod conflicts

- we will be using standard factorio events to interact with other mods

- player settings in storage
  - show_fave_bar_buttons - this is toggled by clicking on the first slot in the favorites_GUI 
  - render_mode - tracks the render_mode of the player so that we can react to events in proper context

- create a function or structure in the control.lua (call it on_first_tick) that will run once for each player when they begin the game either by starting a new game or when loading a save file.

- all players should be able to change all favorites they own. maptags should only be editable by the creator, with the exception that every player should be able to make any maptag a favorite of their own even if created by another player. This is achieved by adding the player's index to the faved_by_players table. This allows for one list of maptags per surface. If a player tries to edit another players maptag, there should be mechanisms in place to disallow editing other than being able to favorite that location
-no need for player permissions beyond what has already been mentioned. 

- as this is a new project, there is no need to tackle migrations just yet

- plan for localization. If opportunities for locale specific phrasing is in order, create the proper entries. Place all of the necessary .cfg files into a folder name locale\en. This folder should contain a settings.cfg, controls.cfg and strings.cfg. All user facing strings should be localized. Use the local\en folder

- wherever possible, use caching strategies to mitigate performance issues. MapTags could be accessed frequently, so develop a strategy to aid performance. 

- this project will be debugged in vscode

- if it is not possible to teleport, the reason should be output to the chat log

- project versioning will be managed manually and by me personally


## mod settings
- we should have runtime per-player settings
  - Favorites Bar On. default = true. This allows for the player to toggle the entire favorites bar display on/off. You are still able to use the teleportation functionality. However, changing this value may wipe all of your current favorites data.
  - Teleport Messages On. default = true. Allows for toggling the output of the teleportation messages in the chat_log
  - Slots. default = 10.  If a user moves from a larger count to a smaller count, all favorites with data should be included in the new collection. If there are more favorites currently than in the new size, first condense all the active favorites into the structure and warn that others will be deleted.
  - Teleport Radius. default = 7. allowable values are 4-20. Number of tiles to offset when trying to teleport to a new location and that location is occupied. The collective mind suggests higher values for denser developments. 



  ## GUI/UX
  #### user flows
  ##### map view operations
  1. User right-clicks in render_mode = chart_view
    - the tag_editor_GUI opens and has a cancel and confirm button on the bottom
    - a button on the top row displays the coordinates that were clicked and allows for direct teleportation to that location. The gui will close after teleporting
    - the tag editor also allows for editing of the tag's data: text, icon, description and display_description. 
    - The text field allows for an icon to be placed into the text. the text and icon fields are stored in the tag object while the description is stored in the maptag
    - the cancel button will disregard any changes and close the gui
    - the confirm button will create or update a maptag. Check for the value "-0" which should always be converted to 0. x and y coords should always allow for at least 3 digits in this field. eg: 000.-1350
    - maptag coords are unique. It should not be possible to have more than one maptag per position
  2. User left-clicks on an existing chart tag in render_mode = chart_view
    - this should bring up the stock editor. No gui from our mod to display, instead our mod listens to the on_chart_tag_modified event and updates any matching maptags
  3. User right-clicks on a chart tag in render_mode = chart_view
    - the tag editor opens and is populated with the information for that maptag
    - upon confirm, the information will be saved back to the maptag and the gui will close
    
##### favorites bar
1. User left clicks on the red heart button. 
- This toggles the show_fav_bar_buttons value and the fave_bar_gui shows or hides the remaining slot buttons according to the state of show_fav_bar_buttons
2. User hovers over a slot.
- a tooltip is shown with the text of the chart_tag and on the next line, the position, converted to a pos_string. the third line should be a snippet of the description - max 25 chars
3. User left-clicks on a favorite slot
- The player is instantly teleported to the favorite location
4. User right-clicks on a favorite slot
- The tag_editor_GUI appears with the information for the selected favorite and allows editing as described prior
5. User clicks and drags a favorite slot
- the red heart slot is not available for this operation
- if the selection is dropped, than the order of the favorites should be updated to reflect the new order and the favorites bar should show the new order




   