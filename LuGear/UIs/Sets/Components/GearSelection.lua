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
	local Filter = SearchText.Text[1]:lower()

	for _, Item in ipairs(items) do
		if Filter == "" or Item.Name:lower():find(Filter, 1, true) == 1 then
			local IsSelected = false

			-- Is selected logic
			for _, GearObject in ipairs(current_gear) do
				if GearObject.Name == Item.Name and GearObject.Augments == Item.Augments then
					IsSelected = true
					break
				end
			end

			if ImGui.Selectable(Item.Name .. "##" .. Item.Id, IsSelected) then
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
