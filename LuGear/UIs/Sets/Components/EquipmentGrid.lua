local ImGui = require("imgui")
local State = require("Core.State")
local ItemSystem = require("Systems.ItemSystem")
local SetSystem = require("Systems.SetSystem")
local Color = require("Libs.Color")
local Theme = require("Libs.Theme")

local TableFlags = bit.bor(ImGuiTableFlags_NoSavedSettings, ImGuiTableFlags_Borders, ImGuiTableFlags_RowBg)

local EquipmentSlots = {
	{ "Main", "Sub", "Ranged", "Ammo" },
	{ "Head", "Neck", "Ear1", "Ear2" },
	{ "Body", "Hands", "Ring1", "Ring2" },
	{ "Back", "Waist", "Legs", "Feet" },
}

---@param text string
---@param max_chars number
---@return string
-- Truncates a string to a maximum length and adds ellipsis if needed
local function TruncateText(text, max_chars)
	if #text > max_chars then
		return text:sub(1, max_chars - 3) .. ".."
	end
	return text
end

---@return nil
-- Renders the 4x4 equipment grid UI component
return function()
	local ThemeColors = Theme.SelectedTheme.Colors

	if ImGui.BeginChild("EquipmentGrid", { 320, 320 }, true) then
		ImGui.Text("Equipment")
		ImGui.Separator()

		if ImGui.BeginTable("EquipTable", 4, TableFlags) then
			for _, Row in ipairs(EquipmentSlots) do
				for _, SlotName in ipairs(Row) do
					local Set = SetSystem.GetSet(State.SelectedJob, State.SelectedSet)
					local SetSlots = Set and Set.Slots and Set.Slots[SlotName]

					local ButtonLabel = SlotName
					local IsActive = (State.SelectedSlot == SlotName)
					local IsFilled = (SetSlots and #SetSlots > 0)
					local FinalColor = ThemeColors.Inactive
					local FinalTextColor = nil

					ImGui.TableNextColumn()

					if IsFilled then
						local FirstItem = SetSlots and SetSlots[1] or nil

						if FirstItem and #SetSlots > 1 then
							ButtonLabel = FirstItem.Name .. " [+" .. (#SetSlots - 1) .. " others" .. "]"
						elseif FirstItem then
							ButtonLabel = FirstItem.Name
						end

						FinalTextColor = ThemeColors.Active
					end

					if IsActive then
						FinalColor = Color.Darken(ThemeColors.Hover, 0.3)
					end

					ImGui.PushStyleColor(ImGuiCol_Button, FinalColor)
					ImGui.PushStyleColor(ImGuiCol_ButtonHovered, ThemeColors.Hover)
					ImGui.PushStyleColor(ImGuiCol_ButtonActive, Color.Lighten(ThemeColors.Hover, 0.2))

					if FinalTextColor then
						ImGui.PushStyleColor(ImGuiCol_Text, FinalTextColor)
					end

					if ImGui.Button(TruncateText(ButtonLabel, 7) .. "##" .. SlotName, { 64, 64 }) then
						if State.SelectedSlot == SlotName then
							State.SelectedSlot = "None"
						else
							State.SelectedSlot = SlotName
							ItemSystem.UpdateFilteredGear(SlotName)
						end
					end

					ImGui.PopStyleColor(FinalTextColor and 4 or 3)

					if ImGui.IsItemHovered() and ButtonLabel ~= SlotName then
						ImGui.BeginTooltip()
						ImGui.TextColored({ 0.4, 0.7, 1.0, 1.0 }, SlotName)
						ImGui.Separator()
						ImGui.Text(ButtonLabel)
						ImGui.EndTooltip()
					end
				end
			end
			ImGui.EndTable()
		end

		ImGui.EndChild()
	end
end
