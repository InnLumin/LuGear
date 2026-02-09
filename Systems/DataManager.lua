local Settings = require("settings")

local DefaultSettings = {
	GlobalConfig = {},
	Jobs = {},
}

local UserSettings = Settings.load(DefaultSettings)

local Module = {}

function Module.Save(job_name, job_data)
	UserSettings.Jobs[job_name] = job_data
	Settings.save()
end

function Module.LoadJobSets() end

return Module
