local Settings = require("settings")
local Constants = require("Constants")

---@class UserSettings
local DefaultSettings = {
	GlobalConfig = {
		IsOpen = { true },
		LevelSyncSetByDefault = true,
	},
	---@type Sets
	Sets = {},
}

local Module = {
	SelectedJob = Constants.JobArray[1],
	SelectedSet = "None",
	SelectedSlot = "None",

	---@class UserSettings
	UserSettings = Settings.load(DefaultSettings),
}

function Module.SaveSettings()
	Settings.save()
end

return Module
