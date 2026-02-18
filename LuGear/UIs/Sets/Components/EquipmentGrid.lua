local ImGui = require("imgui")
local State = require("State")
local FilterGear = require("Libs.FilterGear")
local SetManager = require("Libs.SetManager")
local Color = require("Libs.Color")

local TableFlags = bit.bor(ImGuiTableFlags_NoSavedSettings, ImGuiTableFlags_Borders, ImGuiTableFlags_RowBg)

local EquipmentSlots = {
	{ "Main", "Sub", "Ranged", "Ammo" },
	{ "Head", "Neck", "Ear L", "Ear R" },
	{ "Body", "Hands", "Ring L", "Ring R" },
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

local function GetBlueColor(color)
	local TargetLuma = Color.GetLuminance(color)

	local BlueColor = { 0.3, 0.5, 0.9, color[4] }
	local BlueLuma = Color.GetLuminance(BlueColor)

	local Ratio = TargetLuma / BlueLuma

	return {
		math.min(1, BlueColor[1] * Ratio),
		math.min(1, BlueColor[2] * Ratio),
		math.min(1, BlueColor[3] * Ratio),
		color[4],
	}
end

---@return nil
-- Renders the 4x4 equipment grid UI component
return function()
	if ImGui.BeginChild("EquipmentGrid", { 320, 320 }, true) then
		ImGui.Text("Equipment")
		ImGui.Separator()

		if ImGui.BeginTable("EquipTable", 4, TableFlags) then
			for _, Row in ipairs(EquipmentSlots) do
				for _, SlotName in ipairs(Row) do
					local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)
					local SetSlots = Set and Set.Slots and Set.Slots[SlotName]

					local ButtonLabel = SlotName
					local IsActive = (State.SelectedSlot == SlotName)
					local IsFilled = (SetSlots and #SetSlots > 0)
					local FinalColor = Color.GetColor(ImGuiCol_Button)

					ImGui.TableNextColumn()

					if IsFilled then
						local FirstItem = SetSlots and SetSlots[1] or nil

						if FirstItem and #SetSlots > 1 then
							ButtonLabel = FirstItem.Name .. " [+" .. (#SetSlots - 1) .. " others" .. "]"
						elseif FirstItem then
							ButtonLabel = FirstItem.Name
						end

						FinalColor = GetBlueColor(FinalColor)
					end

					if IsActive then
						FinalColor = Color.Darken(FinalColor, 0.3)
					end

					ImGui.PushStyleColor(ImGuiCol_Button, FinalColor)
					ImGui.PushStyleColor(ImGuiCol_ButtonHovered, Color.Saturate(FinalColor, 0.1))
					ImGui.PushStyleColor(ImGuiCol_ButtonActive, FinalColor)

					if ImGui.Button(TruncateText(ButtonLabel, 7) .. "##" .. SlotName, { 64, 64 }) then
						if State.SelectedSlot == SlotName then
							State.SelectedSlot = "None"
						else
							State.SelectedSlot = SlotName
							FilterGear.UpdateFilteredGear(SlotName)
						end
					end

					ImGui.PopStyleColor(3)

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
