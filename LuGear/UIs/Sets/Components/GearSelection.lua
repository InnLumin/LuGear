local ImGui = require("imgui")
local State = require("State")
local SetManager = require("Libs/SetManager")
local FilterGear = require("Libs/FilterGear")

local SearchText = {
	Text = { "" },
	Size = 256,
}

-- Displays a detailed tooltip for a gear item
---@param gear_data Gear
---@return nil
local function ShowGearTooltip(gear_data)
	if ImGui.IsItemHovered() then
		ImGui.BeginTooltip()
		ImGui.TextColored({ 0.4, 0.7, 1.0, 1.0 }, gear_data.Name)
		ImGui.TextDisabled(string.format("Level: %d | Type: %s", gear_data.Level, gear_data.Type))
		ImGui.Separator()
		ImGui.PushTextWrapPos(300)
		if gear_data.Augments then
			ImGui.Text((gear_data.Description .. "\n" .. gear_data.Augments) or "")
		else
			ImGui.Text(gear_data.Description or "")
		end
		ImGui.PopTextWrapPos()
		ImGui.EndTooltip()
	end
end

-- Renders a selectable menu item for a piece of gear
-- Now simplified to work with standardized table<{ Name: string, Augments?: table<string> }>
---@param gear_data Gear
---@param current_gear table
---@param selected_job string
---@param set_name string
---@param selected_slot string
---@return nil
local function RenderGearSelectable(gear_data, current_gear, selected_job, set_name, selected_slot)
	local IsSelected = false

	-- With standardized structure, always work with table of objects
	for _, GearObject in ipairs(current_gear) do
		if GearObject.Name == gear_data.Name then
			IsSelected = true
			break
		end
	end

	if ImGui.Selectable(gear_data.Name .. "##" .. gear_data.Container .. "_" .. gear_data.Index, IsSelected) then
		SetManager.UpdateSlotForJobSet(selected_job, set_name, selected_slot, gear_data.Name, gear_data.Augments)
	end
	ShowGearTooltip(gear_data)
end

-- Renders the gear search input and clear button
---@return nil
local function RenderSearchBar()
	ImGui.InputText("##Search", SearchText.Text, SearchText.Size)

	if SearchText.Text[1] == "" then
		ImGui.SameLine()
		ImGui.TextDisabled("(Search)")
	end

	if SearchText.Text[1] ~= "" then
		ImGui.SameLine()
		if ImGui.Button("Clear") then
			SearchText.Text[1] = ""
		end
	end
end

-- Groups filtered gear by their base names
---@param filtered_items table<Gear>
---@return table, table
local function GroupFilteredGear(filtered_items)
	local Filter = SearchText.Text[1]:lower()
	local GroupedItems = {}
	local Names = {}

	for _, Gear in ipairs(filtered_items) do
		if Filter == "" or Gear.Name:lower():find(Filter, 1, true) then
			if not GroupedItems[Gear.Name] then
				GroupedItems[Gear.Name] = {}
				table.insert(Names, Gear.Name)
			end
			table.insert(GroupedItems[Gear.Name], Gear)
		end
	end

	table.sort(Names, function(a, b)
		return a:lower() < b:lower()
	end)

	return GroupedItems, Names
end

-- Renders the grouped list of gear items
---@param grouped_items table<Gear>
---@param base_names table
---@param current_gear table
---@param selected_job string
---@param set_name string
---@param selected_slot string
---@return nil
local function RenderGearList(grouped_items, base_names, current_gear, selected_job, set_name, selected_slot)
	for _, Name in ipairs(base_names) do
		local Items = grouped_items[Name]

		if #Items > 1 then
			if ImGui.TreeNodeEx(Name .. "##Group_" .. Name, ImGuiTreeNodeFlags_SpanFullWidth) then
				for _, GearData in ipairs(Items) do
					RenderGearSelectable(GearData, current_gear, selected_job, set_name, selected_slot)
				end
				ImGui.TreePop()
			end
		else
			RenderGearSelectable(Items[1], current_gear, selected_job, set_name, selected_slot)
		end
	end
end

-- Main render function for the gear selection component
---@return nil
return function()
	if ImGui.BeginChild("GearSelection", { 0, 320 }, true) then
		if State.SelectedSlot == "None" or State.SelectedSlot == "" then
			ImGui.TextDisabled("Select a slot on the left to view gear...")
			ImGui.Separator()
			ImGui.EndChild()
			return
		end

		RenderSearchBar()
		ImGui.Separator()

		if ImGui.BeginChild("Items", { 0, 0 }, true) then
			local FilteredItems = FilterGear.GetFilterGear()
			if #FilteredItems == 0 then
				ImGui.TextDisabled("No valid " .. State.SelectedSlot .. " items found in inventory.")
				ImGui.EndChild()
				return
			end

			local GroupedItems, Names = GroupFilteredGear(FilteredItems)

			local CurrentSet = SetManager.GetSet(State.SelectedJob, State.SelectedSet) or { Slots = {} }
			local CurrentSlot = CurrentSet.Slots[State.SelectedSlot] or {}

			RenderGearList(GroupedItems, Names, CurrentSlot, State.SelectedJob, State.SelectedSet, State.SelectedSlot)

			ImGui.EndChild()
		end

		ImGui.EndChild()
	end
end
