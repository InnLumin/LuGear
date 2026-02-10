local ImGui = require("imgui")

local Header = require("Components/Header")
local EquipmentGrid = require("Components/EquipmentGrid")
local GearSelection = require("Components/GearSelection")

return function()
	Header()
	ImGui.Separator()
	EquipmentGrid()
	ImGui.SameLine()
	GearSelection()
end
