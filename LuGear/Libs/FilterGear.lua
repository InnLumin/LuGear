local ResourceManager = AshitaCore:GetResourceManager()
local MemoryManager = AshitaCore:GetMemoryManager()

local State = require("State")
local GetAugments = require("Libs.GetAugments")
local SetManager = require("Libs.SetManager")

local Inventory = MemoryManager:GetInventory()

local SlotBitmasks = {
	["Main"] = 1,
	["Sub"] = 2,
	["Ranged"] = 4,
	["Ammo"] = 8,
	["Head"] = 16,
	["Neck"] = 512,
	["Ear1"] = 6144,
	["Ear2"] = 6144,
	["Body"] = 32,
	["Hands"] = 64,
	["Ring1"] = 24576,
	["Ring2"] = 24576,
	["Back"] = 32768,
	["Waist"] = 1024,
	["Legs"] = 128,
	["Feet"] = 256,
}

local TypeBitmasks = {
	[1] = "Main",
	[2] = "Sub",
	[4] = "Ranged",
	[8] = "Ammo",
	[16] = "Head",
	[512] = "Neck",
	[6144] = "Earring",
	[32] = "Body",
	[64] = "Hands",
	[24576] = "Ring",
	[32768] = "Back",
	[1024] = "Waist",
	[128] = "Legs",
	[256] = "Feet",
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

---@type Item[]
local FilteredGear = {}
local SeenItems = {}

local Module = {}

-- Resolves a readable item type string from resource data
---@param item IItem
---@return ItemType
local function GetItemTypeString(item)
	if not item then
		return "Item"
	end

	-- Check for weapon skill (Dagger, Sword, etc.)
	if item.Skill and item.Skill > 0 and Skills[item.Skill] then
		return Skills[item.Skill]
	end

	if bit.band(item.Slots, 2) ~= 0 and item.Type == 5 then
		return "Shield"
	end

	local Type = TypeBitmasks[item.Slots]
	if Type then
		return Type
	end

	if item.Type == 5 then
		for mask, name in pairs(TypeBitmasks) do
			if bit.band(item.Slots, mask) ~= 0 then
				return name
			end
		end
		return "Armor"
	end

	return "Item"
end

local ElementalReplacements = {
	["\xEF\x1F"] = "Fire",
	["\xEF\x20"] = "Ice",
	["\xEF\x21"] = "Wind",
	["\xEF\x22"] = "Earth",
	["\xEF\x23"] = "Lightning",
	["\xEF\x24"] = "Water",
	["\xEF\x25"] = "Light",
	["\xEF\x26"] = "Dark",
}

---Fixes problems with the description like elemental codes
---@param description string
---@return string
local function FixDescription(description)
	if not description then
		return ""
	end

	description = description:gsub("%%", "%%%%")

	for Icon, Name in pairs(ElementalReplacements) do
		local SafeIcon = Icon:gsub("([^%w])", "%%%1")
		description = description:gsub(SafeIcon, Name)
	end

	return description
end

-- Processes a single inventory item and adds it to the filter list if valid
---@param item item_t
---@param target_mask number
local function ProcessInventoryItem(item, target_mask)
	local ItemData = ResourceManager:GetItemById(item.Id)
	local JobMask = JobBitmasks[State.SelectedJob]

	if not ItemData then
		return
	end

	-- Guard Clause: Slot bitmask check
	if bit.band(ItemData.Slots, target_mask) == 0 then
		return
	end

	-- Guard Clause: Job mask check
	if State.SelectedJob ~= "GLOBAL" and JobMask and bit.band(ItemData.Jobs, JobMask) == 0 then
		return
	end

	local Augments = GetAugments(item, false) -- Might have to check if it's equipped
	local Id = tostring(ItemData.Id) .. Augments

	if SeenItems[Id] then
		return
	end

	table.insert(FilteredGear, {
		Name = ItemData.Name[1],
		Description = FixDescription(ItemData.Description[1]) or "",
		Augments = Augments,
		Type = GetItemTypeString(ItemData),
		Level = ItemData.Level,
		Id = Id, -- Id just for if other systems need a unqiue id
		GhostItem = false,
	})

	SeenItems[Id] = true
end

---Process a single gear item from the set manager
---@param gear SlotValue
local function ProcessSetGear(gear)
	if not gear or not gear.Name or gear.Name == "" then
		return
	end

	local ItemData = ResourceManager:GetItemByName(gear.Name, 0)
	if not ItemData then
		return
	end

	local Augments = gear.Augments or ""
	local Id = tostring(ItemData.Id) .. Augments

	if SeenItems[Id] then
		return
	end

	table.insert(FilteredGear, {
		Name = gear.Name,
		Description = FixDescription(ItemData.Description[1] or ""),
		Augments = Augments,
		Type = GetItemTypeString(ItemData),
		Level = ItemData.Level,
		Id = Id,
		GhostItem = true,
	})

	SeenItems[Id] = true
end

-- Returns the current filtered gear list
---@return Item[]
function Module.GetFilterGear()
	return FilteredGear
end

-- Iterates all containers to update the list of gear for the selected slot
---@param slot_name SlotName
function Module.UpdateFilteredGear(slot_name)
	local TargetMask = SlotBitmasks[slot_name]

	if not TargetMask then
		return
	end

	FilteredGear = {}
	SeenItems = {}

	-- Scan inventory
	for _, ContainerID in pairs(SearchContainers) do
		local ContainerMax = Inventory:GetContainerCountMax(ContainerID)

		for Index = 0, ContainerMax do
			local Item = Inventory:GetContainerItem(ContainerID, Index)

			if Item then
				ProcessInventoryItem(Item, TargetMask)
			end
		end
	end

	-- Scan set manager
	local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)
	local SelectedSlot = Set and Set.Slots[slot_name] or nil

	if SelectedSlot then
		for _, Gear in ipairs(SelectedSlot) do
			ProcessSetGear(Gear)
		end
	end
end

return Module
