local MemoryManager = AshitaCore:GetMemoryManager()
local ResourceManager = AshitaCore:GetResourceManager()

local Event = require("Libs.Event")

local JOB_STRING = "jobs.names_abbr"

local Player = MemoryManager:GetPlayer()

local LastMainJob = Player:GetMainJob()
local LastSubJob = Player:GetSubJob()

local Module = {
	MainJobChange = Event.new(),
	SubJobChange = Event.new(),
}

function Module.GetMainJob()
	return ResourceManager:GetString(JOB_STRING, Player:GetMainJob())
end

function Module.GetSubJob()
	return ResourceManager:GetString(JOB_STRING, Player:GetSubJob())
end

ashita.events.register("packet_in", "subjob_packet_in", function(e)
	if e.id == 0x061 then
		local MainJob = struct.unpack("B", e.data, 0x0C + 0x01)
		local SubJob = struct.unpack("B", e.data, 0x0E + 0x01)

		if MainJob == 0 then
			return
		end

		if MainJob and MainJob ~= LastMainJob then
			local CurrentMainJob = ResourceManager:GetString(JOB_STRING, MainJob)
			Module.MainJobChange:Fire(CurrentMainJob)
			LastMainJob = MainJob
		end

		if SubJob and SubJob ~= LastSubJob then
			local CurrentSubJob = ResourceManager:GetString(JOB_STRING, SubJob)
			Module.SubJobChange:Fire(CurrentSubJob)
			LastSubJob = SubJob
		end
	end
end)

return Module
