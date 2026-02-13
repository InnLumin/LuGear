local ResourceManager = AshitaCore:GetResourceManager()
local MemoryManager = AshitaCore:GetMemoryManager()

local State = require("State")
local GetAugments = require("Libs.GetAugments")

local Inventory = MemoryManager:GetInventory()

---@class Gear
---@field Name string
---@field Augments string
---@field Description string
---@field Type WeaponType
---@field Index number
---@field Container number
---@field Level number

local SlotBitmasks = {
	["Main"] = 1,
	["Sub"] = 2,
	["Ranged"] = 4,
	["Ammo"] = 8,
	["Head"] = 16,
	["Neck"] = 512,
	["Ear L"] = 6144,
	["Ear R"] = 6144,
	["Body"] = 32,
	["Hands"] = 64,
	["Ring L"] = 24576,
	["Ring R"] = 24576,
	["Back"] = 32768,
	["Waist"] = 1024,
	["Legs"] = 128,
	["Feet"] = 256,
}

local SearchContainers = {
	Inventory = 0,
	--MogSafe = 1,
	--MogSafe2 = 9,
	--Storage = 2,
	--MogLocker = 4,
	--MogSatchel = 5,
	--MogSack = 6,
	--MogCase = 7,
	Wardrobe1 = 8,
	Wardrobe2 = 10,
	Wardrobe3 = 11,
	Wardrobe4 = 12,
	Wardrobe5 = 13,
	Wardrobe6 = 14,
	Wardrobe7 = 15,
	Wardrobe8 = 16,
}

local JobBitmasks = {
	["WAR"] = 0x00000002,
	["MNK"] = 0x00000004,
	["WHM"] = 0x00000008,
	["BLM"] = 0x00000010,
	["RDM"] = 0x00000020,
	["THF"] = 0x00000040,
	["PLD"] = 0x00000080,
	["DRK"] = 0x00000100,
	["BST"] = 0x00000200,
	["BRD"] = 0x00000400,
	["RNG"] = 0x00000800,
	["SAM"] = 0x00001000,
	["NIN"] = 0x00002000,
	["DRG"] = 0x00004000,
	["SMN"] = 0x00008000,
	["BLU"] = 0x00010000,
	["COR"] = 0x00020000,
	["PUP"] = 0x00040000,
	["DNC"] = 0x00080000,
	["SCH"] = 0x00100000,
	["GEO"] = 0x00200000,
	["RUN"] = 0x00400000,
}

local Skills = {
	[1] = "Hand-to-Hand",
	[2] = "Dagger",
	[3] = "Sword",
	[4] = "Great Sword",
	[5] = "Axe",
	[6] = "Great Axe",
	[7] = "Scythe",
	[8] = "Polearm",
	[9] = "Katana",
	[10] = "Great Katana",
	[11] = "Club",
	[12] = "Staff",
	[25] = "Archery",
	[26] = "Marksmanship",
	[27] = "Throwing",
}

local Types = {
	[4] = "Shield",
	[5] = "Armor",
	[1] = "Item",
}

---@type table<Gear>
local FilteredGear = {}
local SeenItems = {}

local Module = {}

-- Resolves a readable item type string from resource data
---@param item IItem
---@return string
local function GetItemTypeString(item)
	if not item then
		return "Unknown"
	end

	-- Check for weapon skill (Dagger, Sword, etc.)
	if item.Skill and item.Skill > 0 then
		if Skills[item.Skill] then
			return Skills[item.Skill]
		end
	end

	return Types[item.Type] or "Equipment"
end

-- Processes a single inventory item and adds it to the filter list if valid
---@param item item_t
---@param item_index number
---@param container_id number
---@param target_mask number
---@param job_mask number
local function ProcessInventoryItem(item, item_index, container_id, target_mask, job_mask)
	local ItemData = ResourceManager:GetItemById(item.Id)

	if not ItemData then
		return
	end

	-- Guard Clause: Slot bitmask check
	if bit.band(ItemData.Slots, target_mask) == 0 then
		return
	end

	-- Guard Clause: Job mask check
	if State.SelectedJob ~= "GLOBAL" and job_mask then
		if bit.band(ItemData.Jobs, job_mask) == 0 then
			return
		end
	end

	local IsStackable = (ItemData.StackSize and ItemData.StackSize > 1)
	local AlreadySeen = SeenItems[item.Id] ~= nil

	-- Add item if it's unique, or stackable and not seen yet

	if not IsStackable or not AlreadySeen then
		table.insert(FilteredGear, {
			Name = ItemData.Name[1],
			Description = ItemData.Description[1] or "",
			Augments = GetAugments(item, false), -- Might have to check if it's equipped
			Type = GetItemTypeString(ItemData),
			Index = item_index,
			Container = container_id,
			Level = ItemData.Level,
		})
	end

	-- Track stackable items to avoid duplicates
	if IsStackable then
		SeenItems[item.Id] = true
	end
end

-- Returns the current filtered gear list
---@return table<Gear>
function Module.GetFilterGear()
	return FilteredGear
end

-- Iterates all containers to update the list of gear for the selected slot
---@param slot_name string
function Module.UpdateFilteredGear(slot_name)
	local JobMask = JobBitmasks[State.SelectedJob]
	local TargetMask = SlotBitmasks[slot_name]

	if not TargetMask then
		return
	end

	FilteredGear = {}
	SeenItems = {}

	for _, ContainerID in pairs(SearchContainers) do
		local ContainerMax = Inventory:GetContainerCountMax(ContainerID)

		for Index = 1, ContainerMax do
			local Item = Inventory:GetContainerItem(ContainerID, Index)

			if Item then
				ProcessInventoryItem(Item, Index, ContainerID, TargetMask, JobMask)
			end
		end
	end

	table.sort(FilteredGear, function(a, b)
		return a.Name:lower() < b.Name:lower()
	end)
end

return Module
