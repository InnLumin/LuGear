-- Rules.lua
local ImGui = require("imgui")

---@return nil
-- Renders the Rules configuration tab
return function()
	if ImGui.BeginChild("RulesChild", { 0, 0 }, true) then
		ImGui.Text("Rules")
		ImGui.Separator()

		ImGui.EndChild()
	end
end
