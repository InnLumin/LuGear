local Settings = require("settings")
local Constants = require("Constants")
local JobManager = require("Libs.JobManager")

---@class UserSettings
local DefaultSettings = T({
	GlobalConfig = T({
		LevelSyncSetByDefault = true,
	}),
	---@type Sets
	Sets = {},
})

local Module = {
	SelectedJob = JobManager.GetMainJob(),
	SelectedSet = "None",
	SelectedSlot = "None",

	---@class UserSettings
	UserSettings = Settings.load(DefaultSettings),
}

function Module.Init()
	Settings.register("settings", "settings_update", function(new_settings)
		Module.UserSettings = new_settings
	end)

	JobManager.MainJobChange:Connect(function(new_job)
		Module.SelectedJob = new_job
		Module.SelectedSet = "None"
		Module.SelectedSlot = "None"
	end)
end

function Module.SaveSettings()
	Settings.save()
end

return Module
