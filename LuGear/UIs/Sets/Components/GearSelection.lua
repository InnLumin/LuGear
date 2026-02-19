local ImGui = require("imgui")
local State = require("State")
local SetManager = require("Libs.SetManager")
local FilterGear = require("Libs.FilterGear")

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

	return GroupedItems, Names
end

-- Renders the grouped list of gear items in a Google Sheets-style table
---@param grouped_items table<string, Gear[]>
---@param base_names table
---@param current_gear table
---@param selected_job string
---@param set_name string
---@param selected_slot string
---@return nil
local function RenderGearList(grouped_items, base_names, current_gear, selected_job, set_name, selected_slot)
	local flags = bit.bor(
		ImGuiTableFlags_Borders,
		ImGuiTableFlags_RowBg,
		ImGuiTableFlags_ScrollY,
		ImGuiTableFlags_Resizable,
		ImGuiTableFlags_Sortable
	)

	-- We'll use 3 columns: Name (with grouping), Level, and Location/Type
	if ImGui.BeginTable("GearSheetsTable", 3, flags, { 0, 0 }) then
		ImGui.TableSetupColumn(
			"Name",
			bit.bor(ImGuiTableColumnFlags_WidthStretch, ImGuiTableColumnFlags_DefaultSort),
			0,
			1
		)
		ImGui.TableSetupColumn("Level", ImGuiTableColumnFlags_WidthFixed, 80, 2)
		ImGui.TableSetupColumn("Type", ImGuiTableColumnFlags_WidthFixed, 80, 3)
		ImGui.TableHeadersRow()

		local SortSpecs = ImGui.TableGetSortSpecs()
		if SortSpecs and SortSpecs.SpecsDirty then
			local Spec = SortSpecs.Specs

			table.sort(base_names, function(a, b)
				local ItemA = grouped_items[a][1]
				local ItemB = grouped_items[b][1]

				local function Compare(value_a, value_b)
					if value_a == value_b then
						return nil
					end

					if Spec.SortDirection == ImGuiSortDirection_Descending then
						return value_a > value_b
					else
						return value_a < value_b
					end
				end

				local Result
				if Spec.ColumnUserID == 2 then -- Level
					Result = Compare((ItemA.Level or 0), (ItemB.Level or 0))
				elseif Spec.ColumnUserID == 3 then -- Type
					Result = Compare((ItemA.Type or ""):lower(), (ItemB.Type or ""):lower())
				else -- Name
					Result = Compare(a:lower(), b:lower())
				end

				if Result == nil then
					local NameA, nameB = a:lower(), b:lower()

					return Compare(NameA, nameB) or false
				end

				return Result
			end)

			SortSpecs.SpecsDirty = false -- Mark as handled
		end

		for _, Name in ipairs(base_names) do
			local Items = grouped_items[Name]

			-- If multiple items (like same ring in different bags), we still use a Tree
			-- but we wrap it INSIDE the table row.
			ImGui.TableNextRow()
			ImGui.TableNextColumn()

			if #Items > 1 then
				-- Spreadsheet style group row
				local node_open = ImGui.TreeNodeEx(
					Name .. "##Group_" .. Name,
					bit.bor(ImGuiTreeNodeFlags_SpanFullWidth, ImGuiTreeNodeFlags_OpenOnArrow)
				)

				-- Tooltip for the group (showing info from the first item)
				ShowGearTooltip(Items[1])

				if node_open then
					for _, GearData in ipairs(Items) do
						ImGui.TableNextRow()
						ImGui.TableNextColumn()
						-- Indent sub-items slightly to look like a nested sheet
						ImGui.Indent(10)
						RenderGearSelectable(GearData, current_gear, selected_job, set_name, selected_slot)
						ImGui.Unindent(10)

						-- Fill the other columns for sub-items
						ImGui.TableNextColumn()
						ImGui.TextDisabled(tostring(GearData.Level))
						ImGui.TableNextColumn()
						ImGui.TextDisabled(GearData.Type or "")
					end
					ImGui.TreePop()
				else
					-- Fill columns for closed node
					ImGui.TableNextColumn()
					ImGui.TextDisabled("--")
					ImGui.TableNextColumn()
					ImGui.TextDisabled("Group")
				end
			else
				-- Single item row
				local GearData = Items[1]
				RenderGearSelectable(GearData, current_gear, selected_job, set_name, selected_slot)

				ImGui.TableNextColumn()
				ImGui.Text(tostring(GearData.Level))

				ImGui.TableNextColumn()
				ImGui.Text(GearData.Type or "")
			end
		end

		ImGui.EndTable()
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

		if ImGui.BeginChild("Items", { 0, 0 }, false) then
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
