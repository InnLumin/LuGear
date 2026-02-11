local ImGui = require("imgui")
local Exporter = require("Libs/Exporter")

return function()
	local ExportedSets = { Exporter.ExportJobSets() }

	if ImGui.BeginChild("ExportWindow", { 0, 0 }, true) then
		if ImGui.Button("Copy to Clipboard", { 164, 0 }) then
			ImGui.SetClipboardText(ExportedSets[1])
		end

		if ImGui.BeginChild("ExportTextWindow", { 0, 0 }, true) then
			ImGui.InputTextMultiline(
				"##export_code",
				ExportedSets,
				#ExportedSets[1] + 1024,
				{ 700, 1024 },
				ImGuiInputTextFlags_ReadOnly
			)

			ImGui.EndChild()
		end

		ImGui.EndChild()
	end
end
