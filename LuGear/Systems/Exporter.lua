local SetManager = require("Systems/SetManager")
local State = require("State")

local OrderedSlots = {
	"Main",
	"Sub",
	"Ranged",
	"Ammo",
	"Head",
	"Neck",
	"Ear L",
	"Ear R",
	"Body",
	"Hands",
	"Ring L",
	"Ring R",
	"Back",
	"Waist",
	"Legs",
	"Feet",
}

local Module = {}

---Formats augments as indexed Lua table entries
---@param augments string
---@return string
local function FormatAugments(augments)
	local stats = {}

	-- 1. Standard parsing logic to get the data
	local playerPart, petPart = augments:match("^(.-)Pet:%s*(.*)$")
	if not playerPart then
		playerPart = augments
	end

	local function extract(text, prefix)
		prefix = prefix or ""
		for stat in text:gmatch("([^+-]+[+-]%d+)") do
			local clean = stat:match("^%s*(.-)%s*$")
			if clean and clean ~= "" then
				table.insert(stats, prefix .. clean)
			end
		end
	end

	extract(playerPart)

	if petPart then
		extract(petPart, "Pet: ")
	end

	-- 2. Format the table as a literal string for export
	local formattedEntries = {}
	for i, val in ipairs(stats) do
		-- This wraps the value in the correct quotes and adds the manual [i] =
		-- If the value contains a double quote, we wrap the whole thing in single quotes
		local entry
		if val:find('"') then
			entry = string.format("[%d] = '%s'", i, val)
		else
			entry = string.format('[%d] = "%s"', i, val)
		end
		table.insert(formattedEntries, entry)
	end

	-- Join them together with commas and wrap in curly braces
	return table.concat(formattedEntries, ", ")
end

---Generates a formatted Lua string representing the gear sets for Luashitacast

---@return string
function Module.ExportJobSets()
	local Sets = SetManager.GetSets(State.SelectedJob)

	local Lines = {}
	table.insert(Lines, "local sets = {")

	for SetName, Data in pairs(Sets) do
		-- 1. Determine the correct Set Key Name
		local FinalSetName = SetName
		if Data.LevelSyncSet then
			FinalSetName = SetName .. "_Priority"
		end

		table.insert(Lines, string.format("    %s = {", FinalSetName))

		for _, SlotName in ipairs(OrderedSlots) do
			local GearTable = Data.Slots and Data.Slots[SlotName]

			if SlotName == "Ring L" or SlotName == "Ring R" then
				SlotName = SlotName == "Ring L" and "Ring1" or "Ring2"
			end
			if SlotName == "Ear L" or SlotName == "Ear R" then
				SlotName = SlotName == "Ear L" and "Ear1" or "Ear2"
			end

			if GearTable and #GearTable > 0 then
				if Data.LevelSyncSet then
					-- Level Sync: Export all items, preserving augments
					local GearList = {}
					for _, GearObject in ipairs(GearTable) do
						if GearObject.Augments then
							-- Has augments, keep as object
							local formattedAugments = FormatAugments(GearObject.Augments)
							table.insert(
								GearList,
								string.format('{ Name = "%s", Augment = { %s } }', GearObject.Name, formattedAugments)
							)
						else
							-- No augments, export as string
							table.insert(GearList, string.format('"%s"', GearObject.Name))
						end
					end
					table.insert(Lines, string.format("        %s = { %s },", SlotName, table.concat(GearList, ", ")))
				else
					-- Non-Level Sync: Export only first item
					local FirstGear = GearTable[1]
					if FirstGear.Augments then
						-- Has augments, keep as object
						local formattedAugments = FormatAugments(FirstGear.Augments)
						table.insert(
							Lines,
							string.format(
								'        %s = { Name = "%s", Augment = { %s } },',
								SlotName,
								FirstGear.Name,
								formattedAugments
							)
						)
					else
						-- No augments, export as string
						table.insert(Lines, string.format('        %s = "%s",', SlotName, FirstGear.Name))
					end
				end
			end
		end
		table.insert(Lines, "    },")
	end

	table.insert(Lines, "}")

	local Result = table.concat(Lines, "\n")

	return Result
end

return Module
