# The notes in this file override all other spec sheets

- class names should, for the most part, mimic the file name. 

- _G is the correct and standard way to reference the global environment in Lua and Factorio.
You should keep using _G rather than renaming it to global.

- type annotation definitions use the three-dash (---) style and @field for each property

- A MapPosition can be translated to a ChunkPosition by dividing the x/y values by 32.

- New plan: chart_tag and ext_tag will now be one class -> MapTag. A reference to the chart_tag will be called tag. Do not create files for chart_tag or ext_tag

any fields that are created_by or last_user should always be the player's name