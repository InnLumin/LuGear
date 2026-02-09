local SlotToID = {
	["Main"] = 0,
	["Sub"] = 1,
	["Ranged"] = 2,
	["Ammo"] = 3,
	["Head"] = 4,
	["Body"] = 5,
	["Hands"] = 6,
	["Legs"] = 7,
	["Feet"] = 8,
	["Neck"] = 9,
	["Waist"] = 10,
	["Ear L"] = 11,
	["Ear R"] = 12,
	["Ring L"] = 13,
	["Ring R"] = 14,
	["Back"] = 15,
}

local Module = {}

---@param slot_name string
---@return number|nil
-- Returns the ID of the item currently equipped in the specified slot
local function GetEquippedItemId(slot_name)
	local SlotIndex = SlotToID[slot_name]
	if not SlotIndex then
		print("Error: Invalid slot name provided: " .. tostring(slot_name))
		return nil
	end

	local Inventory = AshitaCore:GetMemoryManager():GetInventory()
	local EquippedItem = Inventory:GetEquippedItem(SlotIndex)

	-- Basic check for empty slot
	if EquippedItem == nil or EquippedItem.Index == 0 then
		return nil
	end

	-- Decomposition of the Index to get the actual item from the container
	-- The Index is a 16-bit value: [High Byte = Container] [Low Byte = Index]
	local Container = bit.rshift(bit.band(EquippedItem.Index, 0xFF00), 8)
	local Index = bit.band(EquippedItem.Index, 0x00FF)

	local InventoryItem = Inventory:GetContainerItem(Container, Index)

	if InventoryItem == nil or InventoryItem.Id <= 0 or InventoryItem.Id == 65535 then
		return nil
	end

	return InventoryItem.Id
end

---@param slot_name string
---@return number|nil
-- Prints the slot bitmask of the item equipped in the given slot name for debugging
function Module.PrintBitmaskOfEquippedSlot(slot_name)
	local ItemId = GetEquippedItemId(slot_name)

	if ItemId then
		local Data = AshitaCore:GetResourceManager():GetItemById(ItemId)
		if Data then
			print(string.format("[Debug] Slot: %s | Item: %s", slot_name, Data.Name[1]))
			print(string.format("[Debug] Bitmask: %d", Data.Slots))
			return Data.Slots
		end
	else
		print("[Debug] Slot " .. slot_name .. " appears to be empty.")
	end
end

return Module
