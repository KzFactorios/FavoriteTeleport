--Storage data structure reference:

Storage._data = storage = {
  mod_version = "" | nil,
    
  players = {
    [player_index] = {
      show_fave_bar_buttons = true/false,
      render_mode = player.render_mode,
      favorites = [{
          slot uint,
          surface_index uint,
          gps string,
          map_tag MapTag,
          slot_locked boolean
        }]
      },
    },
  },
  surfaces = {
    [surface_index] = {
      chart_tags = {
        {
          -- chart_tag objects are to be cached for the surface
          -- these are shared by all players
        }
      },
      map_tags = {
        -- map_tag objects are to be cached for the surface
          -- these are shared by all players
          map_tag = {
            gps,
            faved_by_players {
              list of player indices that have favorited this position
            },
            description,
            display_description
          }
      }
    }
  }    
}



-- favorites are unique by gps
-- chart tags are unique by position
-- map tags are unique by gps
-- my reasoning for the slot property is as follows, I need a property to remember a favorite's slot order. Since I am storing the favorites as one collection, I need a way to filter the collection by surface_index and then put those favorites returned into slot order. The alternative is to create separate favorite collections for each surface and to me, that seems like more complexity than is necessary