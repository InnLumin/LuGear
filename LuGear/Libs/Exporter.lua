local SetManager = require("Libs.SetManager")
local State = require("State")
local Constants = require("Constants")

local Module = {}

---Formats augments as indexed Lua table entries
---@param augments string
---@return string
local function FormatAugments(augments)
	local Stats = {}

	-- 1. Standard parsing logic to get the data
	local PlayerPart, PetPart = augments:match("^(.-)Pet:%s*(.*)$")
	if not PlayerPart then
		PlayerPart = augments
	end

	PlayerPart = PlayerPart:gsub("%.%s+", ".")

	local function extract(text, prefix)
		prefix = prefix or ""
		for stat in text:gmatch("([^+-]+[+-]%d+)") do
			local Clean = stat:match("^%s*(.-)%s*$")
			if Clean and Clean ~= "" then
				table.insert(Stats, prefix .. Clean)
			end
		end
	end

	extract(PlayerPart)

	if PetPart then
		PetPart = PetPart:gsub("%.%s+", ".")
		extract(PetPart, "Pet: ")
	end

	-- 2. Format the table as a literal string for export
	local FormattedEntries = {}
	for Index, Value in ipairs(Stats) do
		local Entry

		if Value:find('"') then
			Entry = string.format("[%d] = '%s'", Index, Value)
		else
			Entry = string.format('[%d] = "%s"', Index, Value)
		end
		table.insert(FormattedEntries, Entry)
	end

	-- Join them together with commas and wrap in curly braces
	return table.concat(FormattedEntries, ", ")
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

		for _, SlotName in ipairs(Constants.Slots) do
			local GearTable = Data.Slots and Data.Slots[SlotName]

			if GearTable and #GearTable > 0 then
				if Data.LevelSyncSet then
					-- Level Sync: Export all items, preserving augments
					local GearList = {}
					for _, GearObject in ipairs(GearTable) do
						if GearObject.Augments and GearObject.Augments ~= "" then
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
					if FirstGear.Augments and FirstGear.Augments ~= "" then
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
