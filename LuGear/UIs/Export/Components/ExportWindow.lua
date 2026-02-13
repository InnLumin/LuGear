local ImGui = require("imgui")
local Exporter = require("Libs/Exporter")

local PreviewFlags = bit.bor(ImGuiInputTextFlags_ReadOnly, ImGuiWindowFlags_HorizontalScrollbar)
local PreviewSize = { -1, -1 }

return function()
	local ExportedSets = { Exporter.ExportJobSets() }

	if ImGui.BeginChild("ExportWindow", { 0, 0 }, true) then
		if ImGui.Button("Copy to Clipboard", { 164, 0 }) then
			ImGui.SetClipboardText(ExportedSets[1])
		end

		if ImGui.BeginChild("ExportPreviewRegion", { 0, 0 }, false) then
			ImGui.PushStyleVar(ImGuiStyleVar_FramePadding, { 0, 0 })

			ImGui.InputTextMultiline("##export_code", ExportedSets, #ExportedSets[1] + 1024, PreviewSize, PreviewFlags)

			ImGui.PopStyleVar()

			ImGui.EndChild()
		end

		ImGui.EndChild()
	end
end
