## Differences Between `ChartTagSpec` and `LuaCustomChartTag` in Factorio's Lua API

**ChartTagSpec** and **LuaCustomChartTag** serve different purposes in the Factorio modding API, and understanding their roles is important for effective mod development.

### **ChartTagSpec**

- **Type:** Data structure (table/concept)
- **Purpose:** Specifies the properties needed to create a new chart tag on the map.
- **Fields:**  
  - `position` (`MapPosition`): Required. Where the tag will be placed.
  - `icon` (`SignalID`): Optional. The icon to display.
  - `text` (`string`): Optional. The text label.
  - `last_user` (`PlayerIdentification`): Optional. Who last modified the tag.
- **Usage:**  
  - Used as an argument when adding a new chart tag, such as with `LuaForce.add_chart_tag`.
  - Think of it as a "blueprint" or a set of instructions for what the tag should look like and where it should go.
- **Lifecycle:**  
  - Exists only at the moment of tag creation; it is not an object you interact with after the tag is created[2][3].

### **LuaCustomChartTag**

- **Type:** Class (runtime object)
- **Purpose:** Represents an actual, live chart tag on the map after it has been created.
- **Properties and Methods:**  
  - `icon`, `text`, `position`, `last_user`: These can be read or modified (with some restrictions).
  - `tag_number`, `force`, `surface`: Metadata about the tag.
  - `destroy()`: Method to remove the tag.
  - `valid`: Whether the tag still exists in the game.
- **Usage:**  
  - Returned by functions like `LuaForce.add_chart_tag` after you create a tag.
  - Used to manipulate, update, or destroy existing tags.
- **Lifecycle:**  
  - Persists as long as the tag exists in the game. You interact with it to change or remove the tag[1].

### **Summary Table**

| Feature                | ChartTagSpec                         | LuaCustomChartTag                |
|------------------------|--------------------------------------|----------------------------------|
| Type                   | Data structure (table/concept)       | Class (runtime object)           |
| Purpose                | Defines what a new tag should be     | Represents an existing tag       |
| When Used              | When creating a new tag              | After tag is created             |
| How Used               | Passed as argument to creation API   | Manipulated via properties/methods|
| Lifecycle              | Temporary, for creation only         | Persistent, until destroyed      |
| Example Usage          | `LuaForce.add_chart_tag(spec)`       | `tag.destroy()`, `tag.text = ...`|

### **Key Takeaways for Developers**

- **ChartTagSpec** is for *creating* tags. It is not an object you keep or manipulate after creation.
- **LuaCustomChartTag** is the *object* you get back after creating a tag, and is what you use to *read, update, or destroy* tags.
- There is no "chart_tag" object in the API-only the concept (`ChartTagSpec`) and the class (`LuaCustomChartTag`).
- You cannot convert a `LuaCustomChartTag` back into a `ChartTagSpec`; the latter is only for creation.

**In summary:**  
Use `ChartTagSpec` to define a tag when creating it, and use `LuaCustomChartTag` to interact with the tag after it exists in the game[1][2][3].

Citations:
[1] https://lua-api.factorio.com/stable/classes/LuaCustomChartTag.html
[2] https://lua-api.factorio.com/stable/concepts/ChartTagSpec.html
[3] https://lua-api.factorio.com/stable/classes/LuaCustomChartTag.html
[4] https://lua-api.factorio.com/stable/concepts/ChartTagSpec.html
[5] https://lua-api.factorio.com/latest/concepts/ChartTagSpec.html
[6] https://lua-api.factorio.com/latest/classes.html
[7] https://lua-api.factorio.com/latest/classes/LuaForce.html
[8] https://www.reddit.com/r/factorio/comments/jbwtt1/could_someone_good_with_lua_and_the_factorio_api/
[9] https://www.reddit.com/r/factorio/comments/5v6mr8/getting_started_with_the_modding_api/
[10] https://lua-api.factorio.com/latest/classes/LuaCustomChartTag.html
[11] https://lua-api.factorio.com/latest/concepts.html
[12] https://steamcommunity.com/app/427520/discussions/0/4693406471885555880/
[13] http://lua-api.hornwitser.no/latest/concepts/Any.html
[14] https://lua-api.factorio.com/latest/classes/LuaCustomTable.html
[15] ftp://kitsussite.ddns.net/games/MORE/Factorio.v1.1.74/doc-html/LuaAccumulatorControlBehavior.html
[16] https://files.unfoa.ru/Factorio/Factorio_2.0.47/doc-html/classes/LuaCustomChartTag.html
[17] https://lua-api.factorio.com/latest/classes/LuaEntity.html
[18] ftp://kitsussite.ddns.net/games/MORE/Factorio.v1.1.74/doc-html/Migrations.html
[19] https://github.com/Arch666Angel/mods/issues/907
[20] https://www.reddit.com/r/factorio/comments/12cgw9c/comparing_the_flowcharts_of_the_major_mods/
[21] https://files.unfoa.ru/Factorio/Factorio_2.0.47/doc-html/classes/LuaControlBehavior.html
[22] https://cdaringe.github.io/factorio-type-kit/posts/get-started
[23] https://lua-api.factorio.com/latest/events.html
[24] https://steamdb.info/patchnotes/16181832/

---
Answer from Perplexity: pplx.ai/share