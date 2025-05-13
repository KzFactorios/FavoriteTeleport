-- Storage.lua
-- Centralized persistent storage handler for mod
-- Handles saving, loading, and schema management for mod data

local Storage = {}

--- Initializes the storage structure if not present
function Storage.init()
  Storage._data = Storage._data or {
    mod_version = nil,
    players = {},
    surfaces = {},
  }
end

--- Returns the root storage table
function Storage.get()
  return Storage._data
end

--- Returns the player-specific storage table
-- @param player_index integer
function Storage.get_player_data(player_index)
  local storage = Storage.get()
  storage.players[player_index] = storage.players[player_index] or {}  
  return storage.players[player_index]
end

--- Returns the surface-specific storage table
-- @param surface_index integer
function Storage.get_surface_data(surface_index)
  local storage = Storage.get()
  storage.surfaces[surface_index] = storage.surfaces[surface_index] or {}
  return storage.surfaces[surface_index]
end

return Storage

--[[
Storage data structure reference:

Storage._data = storage = {
    mod_version = "" | nil,
    
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
          chart_tags = {
            {
              -- chart_tag objects are to be cached for the surface
              -- these are shared by all players
              -- this collection is constructed by calling player.force.findd_chart_tags(surface_index)
            }
          },
          ext_tags = {
            -- ext_tag objects are to be cached for the surface
              -- these are shared by all players
              ext_tag = {
                pos_string,
                faved_by_players {
                  list of player indices that have favorited this position
                },
                description,
                display_description
              }
          }
        }
      }
      ...
    },
    ... -- other global mod data
  }
]]
