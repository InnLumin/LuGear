local ImGui = require("imgui")
local State = require("State")
local SetManager = require("Libs.SetManager")
local FilterGear = require("Libs.FilterGear")

local SearchText = {
	Text = { "" },
	Size = 256,
}

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

-- Renders the grouped list of gear items
---@param items Item[]
---@param current_gear SlotValue[]
local function RenderGearList(items, current_gear)
	local Flags = bit.bor(
		ImGuiTableFlags_Borders,
		ImGuiTableFlags_RowBg,
		ImGuiTableFlags_ScrollY,
		ImGuiTableFlags_Sortable,
		ImGuiTableFlags_Resizable,
		ImGuiTableFlags_NoSavedSettings
	)

	if ImGui.BeginTable("GearSelectionTable", 3, Flags) then
		-- Column Setup
		ImGui.TableSetupColumn("Name", ImGuiTableColumnFlags_WidthStretch, 0, 1)
		ImGui.TableSetupColumn("Lvl", ImGuiTableColumnFlags_WidthFixed, 40, 2)
		ImGui.TableSetupColumn("Type", ImGuiTableColumnFlags_WidthFixed, 120, 3)
		ImGui.TableHeadersRow()

		-- Sort logic
		local SortSpecs = ImGui.TableGetSortSpecs()
		if SortSpecs and SortSpecs.SpecsDirty then
			table.sort(items, function(a, b)
				local Specs = SortSpecs.Specs
				local IsDescending = Specs.SortDirection == ImGuiSortDirection_Descending
				local AttributeA, AttributeB

				-- ColumnUserID 2 is now mapped to "Lvl"
				if Specs.ColumnUserID == 2 then
					AttributeA, AttributeB = a.Level, b.Level
				elseif Specs.ColumnUserID == 3 then -- Type
					AttributeA, AttributeB = a.Type:lower(), b.Type:lower()
				else -- Fallback to name
					AttributeA, AttributeB = a.Name:lower(), b.Name:lower()
				end

				if AttributeA == AttributeB then
					if Specs.ColumnUserID == 1 then
						return false
					end -- Already sorting by name and they are equal

					AttributeA, AttributeB = a.Name:lower(), b.Name:lower()

					if AttributeA == AttributeB then
						return false
					end -- If names are also equal
				end

				if IsDescending then
					return AttributeA > AttributeB
				else
					return AttributeA < AttributeB
				end
			end)
			SortSpecs.SpecsDirty = false
		end

		-- Filter and render
		local Filter = SearchText.Text[1]:lower()

		for _, Item in ipairs(items) do
			if Filter == "" or Item.Name:lower():find(Filter, 1, true) == 1 then
				ImGui.TableNextRow()
				ImGui.TableNextColumn()

				-- Is selected logic
				local IsSelected = false
				for _, GearObject in ipairs(current_gear) do
					local NameMatch = (GearObject.Name == Item.Name)
					local AugmentMatch = (GearObject.Augments or "" == Item.Augments or "")
					if NameMatch and AugmentMatch then
						IsSelected = true
						break
					end
				end

				if ImGui.Selectable(Item.Name .. "##" .. Item.Id, IsSelected, ImGuiSelectableFlags_SpanAllColumns) then
					SetManager.UpdateSlotForJobSet(
						State.SelectedJob,
						State.SelectedSet,
						State.SelectedSlot,
						Item.Name,
						Item.Augments
					)
				end

				-- Tooltip
				if ImGui.IsItemHovered() then
					ImGui.BeginTooltip()
					ImGui.TextColored({ 0.4, 0.7, 1.0, 1.0 }, Item.Name)
					ImGui.TextDisabled(string.format("Level: %d | Type: %s", Item.Level, Item.Type))
					ImGui.Separator()
					ImGui.PushTextWrapPos(300)
					ImGui.Text(Item.Description)
					if Item.Augments ~= "" then
						ImGui.Text(Item.Augments)
					end
					ImGui.PopTextWrapPos()
					ImGui.EndTooltip()
				end

				-- Level Column
				ImGui.TableNextColumn()
				ImGui.Text(tostring(Item.Level))

				-- Type Column
				ImGui.TableNextColumn()
				ImGui.Text(Item.Type)
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

			local CurrentSet = SetManager.GetSet(State.SelectedJob, State.SelectedSet) or { Slots = {} }
			local SlotItems = CurrentSet.Slots[State.SelectedSlot] or {}

			RenderGearList(FilteredItems, SlotItems)

			ImGui.EndChild()
		end

		ImGui.EndChild()
	end
end
