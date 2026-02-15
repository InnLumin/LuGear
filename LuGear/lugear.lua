addon.name = "LuGear"
addon.author = "InnLumin"
addon.version = "1.0.3"
addon.desc = "A helper addon to help make, making luashitacast profiles easier."
addon.link = "https://github.com/InnLumin/LuGear"

local ImGui = require("imgui")
local State = require("State")
local Sets = require("UIs.Sets.Sets")

local WindowFlags = bit.bor(ImGuiWindowFlags_NoSavedSettings, ImGuiWindowFlags_NoResize)
local WindowWidth, WindowHeight = 736, 436

local IsOpen = { false }

-- Callback for addon command
---@return nil
ashita.events.register("command", "lugear_command_callback", function(args)
	local LowerCommand = args.command:lower()

	if LowerCommand == "/lugear" or LowerCommand == "/lg" then
		IsOpen[1] = not IsOpen[1]
		State.SaveSettings()
	end
end)

ashita.events.register("load", "lugear_load_callback", function()
	State.Init()
end)

-- Callback for rendering the UI
---@return nil
ashita.events.register("d3d_present", "lugear_present_callback", function()
	if not IsOpen[1] then
		return
	end

	ImGui.SetNextWindowSize({ WindowWidth, WindowHeight }, ImGui.ImGuiCond_Once)

	if ImGui.Begin("LuGear", IsOpen, WindowFlags) then
		if ImGui.BeginTabBar("MainTabBar") then
			if ImGui.BeginTabItem("Sets") then
				Sets()
				ImGui.EndTabItem()
			end

			ImGui.EndTabBar()
		end

		ImGui.End()
	end
end)
