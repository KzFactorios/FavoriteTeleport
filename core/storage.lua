-- Storage.lua
-- Centralized persistent storage handler for mod
-- Handles saving, loading, and schema management for mod data

local Storage = {}

--- Initializes the storage structure if not present
function Storage.init()
  if not Storage._data then
    Storage._data = {
      mod_version = nil,
      players = {},
      surfaces = {},
    }
  end
end

--- Returns the root storage table
function Storage.get()
  if not Storage._data then Storage.init() end
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

--- Called when a player leaves the game; cleans up their tag ownership and favorites
-- @param player_index integer
-- @param player_name string
function Storage.on_player_left(player_index, player_name)
  local storage = Storage.get()
  -- Remove player_index from all faved_by_players and set last_user to nil if owned
  for surface_index, surface_data in pairs(storage.surfaces) do
    -- Clean up chart_tags
    if surface_data.chart_tags then
      for _, tag in pairs(surface_data.chart_tags) do
        if tag.last_user == player_name then
          tag.last_user = nil
        end
        if tag.faved_by_players then
          for i = #tag.faved_by_players, 1, -1 do
            if tag.faved_by_players[i] == player_index then
              table.remove(tag.faved_by_players, i)
            end
          end
        end
      end
    end
    -- Clean up ext_tags if present
    if surface_data.ext_tags then
      for _, tag in pairs(surface_data.ext_tags) do
        if tag.last_user == player_name then
          tag.last_user = nil
        end
        if tag.faved_by_players then
          for i = #tag.faved_by_players, 1, -1 do
            if tag.faved_by_players[i] == player_index then
              table.remove(tag.faved_by_players, i)
            end
          end
        end
      end
    end
  end
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
