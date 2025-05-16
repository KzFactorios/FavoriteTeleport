the tag editor should make the is_favorite toggle disabled (value should be false) if the player's favorite slots are at maximum. Create a helper function to determine this

the tag editor allows for creating and editing map_tags in the storage.surfaces[surface_index] table.
each map tag has a pos_string which is unique.

the text for a map_tag should be limited to 75 chars and the description should be limited to 75 chars. Check the codebase for any discrepancies for these limits.
the icon value should be saved as a string or a table with primitive values.

when the confirm button is clicked, the input data should be validated.

if it is_favorite then check for available player favorite slots, if there aren't any, change is_favorite to false and continue. There should be another local value to track if this situation arises to trigger a post creation dialog popup indicating that the player slots were full and that they will have to make room for any new favorites. Let's call this value favorite_slots_unavailable

Then we will search the storage.surfaces[player.surface.index].chart_tags collection to find a match to the position (in teleport button text). this will require matching a map_position to a pos_string

if no match is found, this signals that we are creating a new tag.

using the inputs and the player, a new chart_tag should be created thusly:
-- Example: Add a custom chart tag at a specific position
game.forces["player"].add_chart_tag(surface, {
  position = (position from tag_editor {x: x, y:y}),
  icon = {type="item", name="iron-plate"},
  text = input text,
  last_user = player.name
})

if the creation of that chart tag fails while creating a new one, an error message should be logged and shown to the player.

if successful, the chart_tag should be added to storage.surfaces[player.surface.index].chart_tags

if the creation is successful, then we should create a map_tag like so:
example:
map_tag = {
    position = xxx.yyy,
    faved_by_players = {} -- this will add the player_index to the list if it is favorited in the gui
}

also if the entry is_favorite = true, then a favorite should be created in the player's next available open/unused slot. A player cannot have more than the constants.MAX_FAVORITE_SLOTS = 10 (create this constant in constants.lua). The player's favorites should reside in storage.players[player_index].favorites

if is_favorite == true, then a favorite will be created in the next available slot in the player's storage.players[player_index].favorites list

finally the map_tag should be added to storage.surfaces[player.surface.index].map_tags, the dialog data should be cleared and the gui closed.

if favorite_slots_unavailable == true, this is the point where we show a popup modal dialog box to inform the player that they will have to delete a favorite to make room for any new favorites.

## Clarifications and Implementation Notes (as of 2025-05-14)

### 1. Map Tag Structure and pos_string
- The field for the string version of the position should always be named `gps`.
- The terms `position`, `mapposition`, and `map_position` may be used interchangeably for the table form, but `gps` always refers to the string version.
- gps is a string the format s.xxx.yyy where s is the surface_index, xxx is the x coordinate and yyy is the y coordinate.  xxx and yyy are a minimum of 3 digits 
- The `faved_by_players` list must only contain unique player indices (no duplicates).

### 2. Favorite Slot Management
- MAX_FAVORITE_SLOTS should be enforced **per player, per surface** (not globally).
- If a player's remaining open favorite slots for a surface are zero, the tag editor GUI must disable the favorite button and set its value to false.
- A helper function should be created to check for available favorite slots for a player on a given surface.

### 3. Storage Structure
- Always check for and initialize storage tables before inserting (e.g., `storage.players[player_index]`).
- The `favorites` list should be a sparse array: nil values indicate empty slots.
- A helper function should be created to check for available favorite slots.

### 4. Chart Tag Creation and Updates
- If `game.forces["player"].add_chart_tag` fails, show a custom dialog and also use `player.print` to notify the player.
- If a chart_tag already exists at the position, update the data structures with the new info.
- If there is no map_tag for a chart_tag, create a new map_tag; otherwise, update the matching map_tag.

### 5. Validation
- Text and description fields should be trimmed of whitespace before validating their length.
- It is valid for either icon or text to be missing, but if both are empty, raise an exception.

### 6. Dialog Data and GUI Closing
- All dialog data and state should be destroyed after the dialog closes.
- The tag editor should always close after a successful operation.

### 7. Concurrency and Permissions
- Any player may favorite any tag.
- Only the `last_user` may update tag information (except for favoriting/unfavoriting).

### 8. Constants
- `MAX_FAVORITE_SLOTS` should be enforced globally (not per-player or per-surface).

---

_These clarifications are based on user answers and should be followed for all tag editor and favorite logic._


whenever a new chart_tag is added, the storage.surfaces[surface_index].chart_tags collection should be set to nil or empty, forcing the next get to rebuild the collection. However, this operation needs to wait until after we have successfully created the tag. The cache invalidation should also occur in other scenarios (such as tag removal or update)

