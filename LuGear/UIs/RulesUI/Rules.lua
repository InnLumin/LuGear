local ImGui = require("imgui")

-- Renders the Rules configuration tab
---@return nil
return function()
	if ImGui.BeginChild("RulesChild", { 0, 0 }, true) then
		ImGui.Text("Rules")
		ImGui.Separator()

		ImGui.EndChild()
	end
end
