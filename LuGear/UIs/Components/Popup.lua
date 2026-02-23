local ImGui = require("imgui")

local Flags = bit.bor(ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoSavedSettings, ImGuiWindowFlags_NoCollapse)

---@param title string
---@param size table?<number, number>
return function(title, size)
	local IsOpen = { false }

	---@param render_content function
	local function DrawPopup(render_content)
		if IsOpen[1] then
			if size then
				ImGui.SetNextWindowSize(size)
			end

			if ImGui.Begin(title, IsOpen, Flags) then
				render_content()
				ImGui.End()
			end
		end
	end

	local function TogglePopup()
		IsOpen[1] = not IsOpen[1]
	end

	return DrawPopup, TogglePopup
end
