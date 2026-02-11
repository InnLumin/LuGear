local ImGui = require("imgui")
local Header = require("Components/Header")
local ExportWindow = require("UIs/Export/Components/ExportWindow")

return function()
	Header()
	ImGui.Separator()

	ExportWindow()
end
