local SetManager = require("Libs.SetManager")
local State = require("State")

local OrderedSlots = {
	"Main",
	"Sub",
	"Range",
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

local function NormalizeStatName(name)
	name = (name or ""):gsub("^%s+", ""):gsub("%s+$", "")
	name = name:gsub("Critical hit rate", "Crit.hit rate")
	return name
end

---@param augments string
---@return string
local function FormatAugments(augments)
	local Stats = {}

	local PlayerPart, PetPart = augments:match("^(.-)Pet:%s*(.*)$")
	if not PlayerPart then
		PlayerPart = augments
	end

	local function extract(text, prefix)
		prefix = prefix or ""
		if not text or text == "" then
			return
		end

		text = text:gsub("[\r\n]+", " ")
		text = text:gsub("%%%s*Critical hit rate", " Critical hit rate")
		text = text:gsub("%.%s+", ".")
		text = text:gsub("%s+", " ")

		for stat_name, amount in text:gmatch("([^%+%-]-)([%+%-]%d+)") do
			local name = NormalizeStatName(stat_name)
			if name ~= "" then
				table.insert(Stats, prefix .. name .. amount)
			end
		end
	end

	extract(PlayerPart)

	if PetPart then
		extract(PetPart, "Pet: ")
	end

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

	return table.concat(FormattedEntries, ", ")
end

---@return string
function Module.ExportJobSets()
	local Sets = SetManager.GetSets(State.SelectedJob)

	local Lines = {}
	table.insert(Lines, "local sets = {")

	for SetName, Data in pairs(Sets) do
		local FinalSetName = SetName
		if Data.LevelSyncSet then
			FinalSetName = SetName .. "_Priority"
		end

		table.insert(Lines, string.format("    %s = {", FinalSetName))

		for _, RawSlotName in ipairs(OrderedSlots) do
			local ExportSlotName = RawSlotName
			local LookupNames = { RawSlotName }

			if RawSlotName == "Ring L" then
				ExportSlotName = "Ring1"
				LookupNames = { "Ring L", "Ring1" }
			elseif RawSlotName == "Ring R" then
				ExportSlotName = "Ring2"
				LookupNames = { "Ring R", "Ring2" }
			end

			if RawSlotName == "Ear L" then
				ExportSlotName = "Ear1"
				LookupNames = { "Ear L", "Ear1" }
			elseif RawSlotName == "Ear R" then
				ExportSlotName = "Ear2"
				LookupNames = { "Ear R", "Ear2" }
			end

			local GearTable = nil
			if Data.Slots then
				for _, Key in ipairs(LookupNames) do
					local t = Data.Slots[Key]
					if t and #t > 0 then
						GearTable = t
						break
					end
				end
			end

			if GearTable and #GearTable > 0 then
				if Data.LevelSyncSet then
					local GearList = {}
					for _, GearObject in ipairs(GearTable) do
						if GearObject.Augments and GearObject.Augments ~= "" then
							local formattedAugments = FormatAugments(GearObject.Augments)
							table.insert(
								GearList,
								string.format('{ Name = "%s", Augment = { %s } }', GearObject.Name, formattedAugments)
							)
						else
							table.insert(GearList, string.format('"%s"', GearObject.Name))
						end
					end
					table.insert(
						Lines,
						string.format("        %s = { %s },", ExportSlotName, table.concat(GearList, ", "))
					)
				else
					local FirstGear = GearTable[1]
					if FirstGear.Augments and FirstGear.Augments ~= "" then
						local formattedAugments = FormatAugments(FirstGear.Augments)
						table.insert(
							Lines,
							string.format(
								'        %s = { Name = "%s", Augment = { %s } },',
								ExportSlotName,
								FirstGear.Name,
								formattedAugments
							)
						)
					else
						table.insert(
							Lines,
							string.format('        %s = "%s",', ExportSlotName, FirstGear.Name)
						)
					end
				end
			end
		end

		table.insert(Lines, "    },")
	end

	table.insert(Lines, "}")

	return table.concat(Lines, "\n")
end

return Module
