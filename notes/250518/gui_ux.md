# FavoriteTeleport – GUI & UX Design

## Favorites Bar (fave_bar_GUI)
- Up to N favorite slots (default 10, configurable per-player) for the current surface.
- First slot is a red heart icon; toggles visibility of the rest of the bar.
- Each slot shows the favorite's icon (if set) and slot number.
- Left-click: teleport to favorite location.
- Right-click: open tag editor GUI for that favorite.
- Drag-and-drop: reorder favorites (except the heart slot).
- Tooltip: shows tag text, position, and description snippet.

## Tag Editor (tag_editor_GUI)
- Opens on right-click in map view or on a favorite slot.
- Allows editing tag text, icon, description, and position.
- Cancel/Confirm buttons; confirm validates and saves.
- Only one maptag per position.
- If editing another player's tag, only allow favoriting, not editing.

## Map View Operations
- All teleport and tag editor actions are available in map view.
- Robust error handling and user feedback for invalid actions.

## General
- Modern, visually appealing, and responsive GUI.
- Adapts to UI scale and screen size.
- Uses Factorio styling and idioms.
- Tooltips, error handling, and chat messages for user feedback.
