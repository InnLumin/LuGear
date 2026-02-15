local ResourceManager = AshitaCore:GetResourceManager()

local State = require("State")

local Module = {}

-- Helper to sort priority list by level (Highest -> Lowest)
---@param list SlotValue
local function SortLevelSyncList(list)
	table.sort(list, function(a, b)
		-- Extract names from objects

		local ItemA = ResourceManager:GetItemByName(a.Name, 0)
		local ItemB = ResourceManager:GetItemByName(b.Name, 0)

		local LevelA = ItemA and ItemA.Level or 0
		local LevelB = ItemB and ItemB.Level or 0

		return LevelA > LevelB -- Descending order
	end)
end

---@return Sets
local function GetUserSets()
	return State.UserSettings.Sets
end

---@param job_name JobName
---@param set_name string
---@return GearSet | nil
function Module.GetSet(job_name, set_name)
	local Sets = Module.GetSets(job_name)

	if not Sets then
		return nil
	end

	return Sets[set_name]
end

---@param job_name JobName
---@return SetDefinitions | nil
function Module.GetSets(job_name)
	local UserSets = GetUserSets()
	if not UserSets then
		return nil
	end

	return UserSets[job_name]
end

---@param job_name JobName
---@param set_name string
---@param level_sync_set boolean?
function Module.AddSet(job_name, set_name, level_sync_set)
	local Sets = GetUserSets()
	local LevelSyncSetByDefault = State.UserSettings.GlobalConfig.LevelSyncSetByDefault

	if not Sets[job_name] then
		Sets[job_name] = {}
	end

	if level_sync_set == nil then
		level_sync_set = LevelSyncSetByDefault
	end

	if not Sets[job_name][set_name] then
		Sets[job_name][set_name] = {
			LevelSyncSet = level_sync_set,
			Slots = {},
		}
		State.SaveSettings()
	end
end

---@param job_name JobName
---@param old_name string
---@param new_name string
function Module.RenameSet(job_name, old_name, new_name)
	if old_name == new_name or new_name == "" then
		return
	end

	local Sets = Module.GetSets(job_name)

	if Sets and Sets[old_name] then
		Sets[new_name] = Sets[old_name]
		Sets[old_name] = nil
		State.SaveSettings()
	end
end

---@param job_name JobName
---@param set_name string
function Module.DeleteSet(job_name, set_name)
	if Sets[job_name] then
		Sets[job_name][set_name] = nil
		State.SaveSettings()
	end
end

---@param job_name JobName
---@param set_name string
function Module.ToggleLevelSync(job_name, set_name)
	local Set = Module.GetSet(job_name, set_name)
	if not Set then
		return
	end

	Set.LevelSyncSet = not Set.LevelSyncSet
	State.SaveSettings()
end

---@param job_name JobName
---@param set_name string
---@param slot_name SlotName
---@param item_name string
---@param augments string?
function Module.UpdateSlotForJobSet(job_name, set_name, slot_name, item_name, augments)
	local Set = Module.GetSet(job_name, set_name)
	if not Set then
		return
	end

	local SlotGear = Set.Slots[slot_name] or {}

	-- Find existing item in the list
	local FoundIndex = nil
	for Index, GearObject in ipairs(SlotGear) do
		if GearObject.Name and GearObject.Name == item_name then
			FoundIndex = Index
			break
		end
	end

	if FoundIndex then
		-- Remove the item if it exists
		table.remove(SlotGear, FoundIndex)
	else
		-- Add the new item
		local GearObject = { Name = item_name }
		if augments then
			GearObject.Augments = augments
		end
		table.insert(SlotGear, GearObject)
	end

	-- Sort by level for level sync sets
	if Set.LevelSyncSet then
		SortLevelSyncList(SlotGear)
	end

	Set.Slots[slot_name] = SlotGear

	State.SaveSettings()
end

return Module
