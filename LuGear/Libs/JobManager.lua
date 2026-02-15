local MemoryService = AshitaCore:GetMemoryManager()
local ResourceService = AshitaCore:GetResourceManager()

local Event = require("Libs.Event")

local JOB_STRING = "jobs.names_abbr"

local MainJobChange = Event.new()
local SubJobChange = Event.new()

local Player = MemoryService:GetPlayer()

local LastMainJob = Player:GetMainJob()
local LastSubJob = Player:GetSubJob()

local Module = {
	MainJobChange = MainJobChange,
	SubJobChange = SubJobChange,
}

function Module.GetMainJob()
	return ResourceService:GetString(JOB_STRING, Player:GetMainJob())
end

function Module.GetSubJob()
	return ResourceService:GetString(JOB_STRING, Player:GetSubJob())
end

ashita.events.register("packet_in", "subjob_packet_in", function(e)
	if e.id == 0x061 then
		local MainJob = struct.unpack("B", e.data, 0x0C + 0x01)
		local SubJob = struct.unpack("B", e.data, 0x0E + 0x01)

		if MainJob == 0 then
			return
		end

		if MainJob and MainJob ~= LastMainJob then
			local CurrentMainJob = ResourceService:GetString(JOB_STRING, MainJob)
			MainJobChange:Fire(CurrentMainJob)
			LastMainJob = MainJob
		end

		if SubJob and SubJob ~= LastSubJob then
			local CurrentSubJob = ResourceService:GetString(JOB_STRING, SubJob)
			SubJobChange:Fire(CurrentSubJob)
			LastSubJob = SubJob
		end
	end
end)

return Module
