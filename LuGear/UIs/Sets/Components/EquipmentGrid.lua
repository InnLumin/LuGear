local ImGui = require("imgui")
local State = require("State")
local FilterGear = require("Libs.FilterGear")
local SetManager = require("Libs.SetManager")
local Color = require("Libs.Color")

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

---@return nil
-- Renders the 4x4 equipment grid UI component
return function()
	if ImGui.BeginChild("EquipmentGrid", { 320, 320 }, true) then
		ImGui.Text("Equipment")
		ImGui.Separator()

		local TableFlags = bit.bor(ImGuiTableFlags_NoSavedSettings, ImGuiTableFlags_Borders, ImGuiTableFlags_RowBg)

		if ImGui.BeginTable("EquipTable", 4, TableFlags) then
			for _, Row in ipairs(EquipmentSlots) do
				for _, SlotName in ipairs(Row) do
					local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)
					local SetSlots = Set and Set.Slots and Set.Slots[SlotName]

					local ButtonLabel = SlotName
					local IsActive = (State.SelectedSlot == SlotName)

					ImGui.TableNextColumn()

					if SetSlots and #SetSlots > 1 then
						local FirstItem = SetSlots[1]
						ButtonLabel = FirstItem.Name .. " [+" .. (#SetSlots - 1) .. " others" .. "]"
					elseif SetSlots and #SetSlots == 1 then
						local FirstItem = SetSlots[1]
						ButtonLabel = FirstItem.Name
					end

					if IsActive then
						local R, G, B, A = ImGui.GetStyleColorVec4(ImGuiCol_Button)
						local ButtonColor = { R, G, B, A }
						local DarkenButton = Color.DarkenColor(ButtonColor, 0.2)

						ImGui.PushStyleColor(ImGuiCol_Button, DarkenButton)
						ImGui.PushStyleColor(ImGuiCol_ButtonHovered, DarkenButton)
						ImGui.PushStyleColor(ImGuiCol_ButtonActive, DarkenButton)
					end

					if ImGui.Button(TruncateText(ButtonLabel, 7) .. "##" .. SlotName, { 64, 64 }) then
						State.SelectedSlot = SlotName
						FilterGear.UpdateFilteredGear(SlotName)
					end

					if IsActive then
						ImGui.PopStyleColor(3)
					end

					if ImGui.IsItemHovered() and ButtonLabel ~= SlotName then
						ImGui.BeginTooltip()
						ImGui.TextColored({ 0.4, 0.7, 1.0, 1.0 }, SlotName) -- Blue category header
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
