local ImGui = require("imgui")
local State = require("State")
local Constants = require("Constants")
local FilterGear = require("Libs.FilterGear")
local SetManager = require("Libs.SetManager")
local Exporter = require("Libs.Exporter")
local Popup = require("Components.Popup")

local LevelSyncSetByDefault = State.UserSettings.GlobalConfig.LevelSyncSetByDefault

local NewSetData = {
	Name = { "" },
	IsLevelSync = { LevelSyncSetByDefault },
	Size = 64,
}

---@return nil
-- Renders the job selection combo box
local function JobSelection()
	ImGui.AlignTextToFramePadding()
	ImGui.Text("Job:")
	ImGui.SameLine()

	ImGui.SetNextItemWidth(90)

	if ImGui.BeginCombo("##JobCombo", State.SelectedJob) then
		for Index, JobName in ipairs(Constants.JobArray) do
			local IsSelected = (State.SelectedJob == JobName)

			if ImGui.Selectable(JobName, IsSelected) then
				State.SelectedJob = JobName
				if State.SelectedSlot then
					FilterGear.UpdateFilteredGear(State.SelectedSlot)
				end
				if State.SelectedSet then
					State.SelectedSet = "None"
				end
			end

			if IsSelected then
				ImGui.SetItemDefaultFocus()
			end
		end
		ImGui.EndCombo()
	end
end

---@return nil
-- Renders the set selection combo box for the current job
local function SetSelection()
	ImGui.AlignTextToFramePadding()
	ImGui.Text("Current Set:")
	ImGui.SameLine()
	ImGui.SetNextItemWidth(120)

	local Sets = SetManager.GetSets(State.SelectedJob)

	if ImGui.BeginCombo("##SetCombo", State.SelectedSet) then
		if Sets then
			for Name, _ in pairs(Sets) do
				if ImGui.Selectable(Name, State.SelectedSet == Name) then
					State.SelectedSet = Name
				end
			end
		end
		ImGui.EndCombo()
	end
end

local NewSetName = { "" }
local NewSetLevelSync = { LevelSyncSetByDefault }
local NewSetSize = { 248, 0 }
local NewSetPopup, ToggleNewSetPopup = Popup("New Set", "NewSetPopup", NewSetSize)

-- Renders the button and modal for creating a new gear set
---@return nil
local function NewSet()
	if ImGui.Button("New Set") then
		ToggleNewSetPopup()
	end

	NewSetPopup(function()
		ImGui.Text("Name")
		ImGui.InputText("##popup_setname", NewSetName, #NewSetName[1] + 1024)
		ImGui.Checkbox("Level Sync", NewSetLevelSync)

		ImGui.Separator()

		if ImGui.Button("Create", { 120, 0 }) then
			local Name = NewSetName[1]

			if Name ~= "" then
				SetManager.AddSet(State.SelectedJob, Name, NewSetLevelSync[1])

				NewSetName[1] = ""
				NewSetLevelSync[1] = LevelSyncSetByDefault
				ToggleNewSetPopup()
			end
		end

		ImGui.SameLine()

		if ImGui.Button("Cancel", { 120, 0 }) then
			ToggleNewSetPopup()
		end
	end)
end

local EditSetName = { "" }
local EditLevelSyncSet = { false }
local EditSize = { 248, 0 }
local DrawEditPopup, ToggleEditPopup = Popup("Edit", "HeaderEdit", EditSize)

---@return nil
-- Renders the options button and modal for editing an existing set
local function EditSet()
	if State.SelectedSet == "" or State.SelectedSet == "None" then
		return
	end

	if ImGui.Button("Edit") then
		EditSetName[1] = State.SelectedSet

		local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)
		local IsLevelSyncSet = State.UserSettings.GlobalConfig.LevelSyncSetByDefault

		if Set then
			IsLevelSyncSet = Set.LevelSyncSet
		end

		EditLevelSyncSet[1] = IsLevelSyncSet
		ToggleEditPopup()
	end

	DrawEditPopup(function()
		ImGui.Text("Rename")
		ImGui.InputText("##edit_setname", EditSetName, #EditSetName[1] + 1024)

		ImGui.Checkbox("Level Sync", EditLevelSyncSet)

		ImGui.Separator()

		-- Save
		if ImGui.Button("Save Changes", { 120, 0 }) then
			local OldName = State.SelectedSet
			local NewName = EditSetName[1]

			SetManager.RenameSet(State.SelectedJob, OldName, NewName)

			local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)

			if Set and Set.LevelSyncSet ~= EditLevelSyncSet[1] then
				SetManager.ToggleLevelSync(State.SelectedJob, State.SelectedSet)
			end

			ToggleEditPopup()
		end

		ImGui.SameLine()

		-- Delete
		if ImGui.Button("Delete Set", { 120, 0 }) then
			SetManager.DeleteSet(State.SelectedJob, State.SelectedSet)
			ToggleEditPopup()
		end

		--- Cancel
		if ImGui.Button("Cancel", EditSize) then
			ToggleEditPopup()
		end
	end)
end

local ExportText = { "" }
local ExportSize = { 512, 0 }
local DrawExportPopup, ToggleExport = Popup("Export", "HeaderExport", ExportSize)

---@return nil
local function ExportSet()
	if State.SelectedSet == "" or State.SelectedSet == "None" then
		return
	end

	if ImGui.Button("Export" .. "##" .. "HeaderExportBtn") then
		ExportText[1] = Exporter.ExportJobSets()
		ToggleExport()
	end

	DrawExportPopup(function()
		ImGui.InputTextMultiline(
			"##export_code",
			ExportText,
			#ExportText[1] + 1024,
			{ -1, 200 },
			ImGuiInputTextFlags_ReadOnly
		)

		ImGui.Separator()

		if ImGui.Button("Copy to Clipboard", ExportSize) then
			ImGui.SetClipboardText(ExportText[1])
		end
		if ImGui.Button("Close", ExportSize) then
			ToggleExport()
		end
	end)
end

return function()
	if ImGui.BeginChild("Header", { 720, 40 }, true) then
		JobSelection()
		ImGui.SameLine()

		SetSelection()
		ImGui.SameLine()

		NewSet()
		ImGui.SameLine()

		EditSet()
		ImGui.SameLine()

		ExportSet()

		ImGui.EndChild()
	end
end
