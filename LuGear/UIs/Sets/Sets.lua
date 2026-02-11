local ImGui = require("imgui")
local Header = require("Components/Header")
local EquipmentGrid = require("UIs/Sets/Components/EquipmentGrid")
local GearSelection = require("UIs/Sets/Components/GearSelection")

return function()
	Header()
	ImGui.Separator()
	EquipmentGrid()
	ImGui.SameLine()
	GearSelection()
end
