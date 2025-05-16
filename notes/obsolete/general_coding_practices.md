
-- always try to observe best-practices, factorio protocols and gang of four

## Use Gang of four design patterns whenever possible

-- Gang of Four (GoF) Design Patterns Applied (as of 2025-05-15):

- Strategy Pattern: Used in tag_editor_GUI_validation.lua. Each validation rule is a strategy function, making validation logic modular and extensible.
- Builder Pattern: Used in tag_editor_GUI_builder.lua. The tag editor GUI is constructed using a formal builder object with chainable methods for clarity and extensibility.
- Command Pattern: Used in tag_editor_GUI_events.lua. Each GUI action (confirm, delete, move, etc.) is encapsulated as a command object, making it easier to extend, test, or add undo/redo in the future.

- These patterns improve modularity, maintainability, and extensibility throughout the codebase. Apply similar patterns where appropriate as the project grows.


## Personal preferences
I prefer a blank line above any comment blocks unless they are the top of the page. Successive single line comments should be treated as a block.

