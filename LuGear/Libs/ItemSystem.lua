local ResourceManager = AshitaCore:GetResourceManager()
local MemoryManager = AshitaCore:GetMemoryManager()

local State = require("State")
local GetAugments = require("Libs.GetAugments")
local SetManager = require("Libs.SetManager")
local Constants = require("Constants")

-- Slot bitmasks for bitwise operations
local SlotBitmasks = {
	[Constants.SlotsEnum.Main] = 1,
	[Constants.SlotsEnum.Sub] = 2,
	[Constants.SlotsEnum.Range] = 4,
	[Constants.SlotsEnum.Ammo] = 8,
	[Constants.SlotsEnum.Head] = 16,
	[Constants.SlotsEnum.Neck] = 512,
	[Constants.SlotsEnum.Ear1] = 6144,
	[Constants.SlotsEnum.Ear2] = 6144,
	[Constants.SlotsEnum.Body] = 32,
	[Constants.SlotsEnum.Hands] = 64,
	[Constants.SlotsEnum.Ring1] = 24576,
	[Constants.SlotsEnum.Ring2] = 24576,
	[Constants.SlotsEnum.Back] = 32768,
	[Constants.SlotsEnum.Waist] = 1024,
	[Constants.SlotsEnum.Legs] = 128,
	[Constants.SlotsEnum.Feet] = 256,
}

-- Job bitmasks for bitwise operations
local JobBitmasks = {
	[Constants.JobsEnum.WAR] = 0x00000002,
	[Constants.JobsEnum.MNK] = 0x00000004,
	[Constants.JobsEnum.WHM] = 0x00000008,
	[Constants.JobsEnum.BLM] = 0x00000010,
	[Constants.JobsEnum.RDM] = 0x00000020,
	[Constants.JobsEnum.THF] = 0x00000040,
	[Constants.JobsEnum.PLD] = 0x00000080,
	[Constants.JobsEnum.DRK] = 0x00000100,
	[Constants.JobsEnum.BST] = 0x00000200,
	[Constants.JobsEnum.BRD] = 0x00000400,
	[Constants.JobsEnum.RNG] = 0x00000800,
	[Constants.JobsEnum.SAM] = 0x00001000,
	[Constants.JobsEnum.NIN] = 0x00002000,
	[Constants.JobsEnum.DRG] = 0x00004000,
	[Constants.JobsEnum.SMN] = 0x00008000,
	[Constants.JobsEnum.BLU] = 0x00010000,
	[Constants.JobsEnum.COR] = 0x00020000,
	[Constants.JobsEnum.PUP] = 0x00040000,
	[Constants.JobsEnum.DNC] = 0x00080000,
	[Constants.JobsEnum.SCH] = 0x00100000,
	[Constants.JobsEnum.GEO] = 0x00200000,
	[Constants.JobsEnum.RUN] = 0x00400000,
}

local TypeBitmasks = {
	[1] = "Main",
	[2] = "Sub",
	[4] = "Range",
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

---@type table<string, Item>
local ItemCache = {}

---@type Item[]
local FilteredItems = {}

local IsDirty = true

local Inventory = MemoryManager:GetInventory()

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

---comment
---@param item item_t
local function ProcessInventoryItem(item)
	local RItem = ResourceManager:GetItemById(item.Id)
	if not RItem then
		return
	end

	local Augments = GetAugments(item, RItem)
	local Id = tostring(RItem.Id) .. Augments

	if ItemCache[Id] then
		return
	end

	ItemCache[Id] = {
		Name = RItem.Name[1],
		Description = FixDescription(RItem.Description[1]) or "",
		Augments = Augments,
		Type = GetItemTypeString(RItem),
		Level = RItem.Level,
		Id = Id, -- Id just for if other systems need a unqiue id
		SlotId = RItem.Slots,
		JobId = RItem.Jobs,
		GhostItem = false,
	}
end

---Process a single gear item from the set manager
---@param gear SlotValue
local function ProcessSetGear(gear)
	if not gear or not gear.Name or gear.Name == "" then
		return
	end

	local RItem = ResourceManager:GetItemByName(gear.Name, 0)
	if not RItem then
		return
	end

	local Augments = gear.Augments or ""
	local Id = tostring(RItem.Id) .. Augments

	if ItemCache[Id] then
		return
	end

	ItemCache[Id] = {
		Name = gear.Name,
		Description = FixDescription(RItem.Description[1] or ""),
		Augments = Augments,
		Type = GetItemTypeString(RItem),
		Level = RItem.Level,
		Id = Id,
		SlotId = RItem.Slots,
		JobId = RItem.Jobs,
		GhostItem = true,
	}
end

function Module.Rescan()
	Module.ClearCache()

	-- Scan inventory
	for _, ContainerID in pairs(SearchContainers) do
		local ContainerMax = Inventory:GetContainerCountMax(ContainerID)

		for Index = 1, ContainerMax do
			local Item = Inventory:GetContainerItem(ContainerID, Index)

			if Item then
				ProcessInventoryItem(Item)
			end
		end
	end

	-- Scan set manager
	local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)
	local SelectedSlot = Set and Set.Slots[State.SelectedSlot] or nil

	if SelectedSlot then
		for _, Gear in ipairs(SelectedSlot) do
			ProcessSetGear(Gear)
		end
	end

	IsDirty = false
end

function Module.CacheDirty(value)
	if type(value) ~= "boolean" or IsDirty == value then
		return
	end

	IsDirty = value
end

function Module.ClearCache()
	ItemCache = {}
	FilteredItems = {}
	IsDirty = true
end

---Returns a table of items for that slot and optionally job.
---@param slot_name string
---@param job_name string?
---@return Item[]
function Module.GetItemsFor(slot_name, job_name)
	if IsDirty then
		Module.Rescan()
	end

	local TargetSlotId = slot_name and SlotBitmasks[slot_name] or nil
	local TargetJobId = job_name and JobBitmasks[job_name] or nil
	local Key = tostring(TargetSlotId) .. tostring(TargetJobId or "GLOBAL")

	if FilteredItems[Key] then
		return FilteredItems[Key]
	end

	local Results = {}

	for _, item in pairs(ItemCache) do
		if TargetSlotId and bit.band(item.SlotId, TargetSlotId) ~= 0 then
			if not TargetJobId or bit.band(item.JobId, TargetJobId) ~= 0 or job_name == "GLOBAL" then
				table.insert(Results, item)
			end
		end
	end

	FilteredItems[Key] = Results

	return Results
end

return Module
