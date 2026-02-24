local ImGui = require("imgui")

local Module = {}

function Module.CenterNextWindow(condition)
	local IO = ImGui.GetIO()
	local CenterX = IO.DisplaySize.x / 2
	local CenterY = IO.DisplaySize.y / 2

	ImGui.SetNextWindowPos({ CenterX, CenterY }, condition or ImGuiCond_Always, { 0.5, 0.5 })
end

---Returns a width size based on text and padding.
---@param text string
---@param padding number?
---@return number
function Module.AddPaddingToText(text, padding)
	padding = padding or 10

	local Width, _ = ImGui.CalcTextSize(text)
	return Width + (padding * 2)
end

return Module
