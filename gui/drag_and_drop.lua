-- gui/drag_and_drop.lua
-- Shared drag-and-drop logic for FavoriteTeleport GUIs

local DragAndDrop = {}

--- Checks if a slot is locked and cannot be moved
function DragAndDrop.is_slot_locked(slot)
  return slot and slot.slot_locked == true
end

--- Swaps two slots in a favorites array, respecting slot_locked
function DragAndDrop.swap_slots(favorites, i, j)
  if DragAndDrop.is_slot_locked(favorites[i]) or DragAndDrop.is_slot_locked(favorites[j]) then
    return false -- Cannot swap locked slots
  end
  favorites[i], favorites[j] = favorites[j], favorites[i]
  return true
end

--- Moves a slot from i to j, shifting others, respecting slot_locked
function DragAndDrop.move_slot(favorites, i, j)
  if DragAndDrop.is_slot_locked(favorites[i]) or DragAndDrop.is_slot_locked(favorites[j]) then
    return false
  end
  local slot = table.remove(favorites, i)
  table.insert(favorites, j, slot)
  return true
end

return DragAndDrop
