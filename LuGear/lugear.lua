-- LuGear.lua | Main root file that sets up the UI

addon.name = "LuGear"
addon.author = "InnLumin"
addon.version = "1.0"
addon.desc = "A helper addon to help make, making luashitacast profiles easier."

local Rules = require("UIs/RulesUI/Rules")
local Sets = require("UIs/SetsUI/Sets")
local State = require("State")

local ImGui = require("imgui")

local WindowFlags = bit.bor(ImGuiWindowFlags_NoSavedSettings, ImGuiWindowFlags_NoResize)
local WindowWidth, WindowHeight = 736, 436

local IsOpen = State.UserSettings.GlobalConfig.IsOpen

-- Callback for addon command
---@return nil
ashita.events.register("command", "lugear_command_callback", function(args)
	local LowerCommand = args.command:lower()

	if LowerCommand == "/lugear" or LowerCommand == "/lg" then
		IsOpen[1] = not IsOpen[1]
		State.SaveSettings()
	end
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

			-- if ImGui.BeginTabItem("Rules") then
			-- 	Rules()
			-- 	ImGui.EndTabItem()
			-- end

			ImGui.EndTabBar()
		end

		ImGui.End()
	end
end)
