-- Header.lua

local State = require("State")
local FilterGear = require("Systems/FilterGear")
local SetManager = require("Systems/SetManager")
local Exporter = require("Systems/Exporter")
local Constants = require("Constants")

local imgui = require("imgui")
local ImGui = imgui

local LevelSyncSetByDefault = State.UserSettings.GlobalConfig.LevelSyncSetByDefault

local NewSetData = {
	Name = { "" },
	IsLevelSync = { LevelSyncSetByDefault },
	Size = 64,
}

local EditSetData = {
	Name = { "" },
	IsLevelSync = { false },
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

	local PreviewName = State.SelectedSet

	if ImGui.BeginCombo("##SetCombo", PreviewName) then
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

---@return nil
-- Renders the button and modal for creating a new gear set
local function NewSet()
	if ImGui.Button("New Set") then
		ImGui.OpenPopup("New Set Popup")
	end

	if ImGui.BeginPopupModal("New Set Popup", nil, ImGuiWindowFlags_AlwaysAutoResize) then
		ImGui.Text("Gear set for: " .. State.SelectedJob)
		ImGui.Separator()

		ImGui.Text("Name")
		ImGui.InputText("##popup_setname", NewSetData.Name, NewSetData.Size)

		ImGui.Checkbox("Level Sync", NewSetData.IsLevelSync)

		ImGui.Separator()

		if ImGui.Button("Create", { 120, 0 }) then
			local Name = NewSetData.Name[1]

			if Name ~= "" then
				SetManager.AddSet(State.SelectedJob, Name, NewSetData.IsLevelSync[1])

				State.SelectedSet = Name

				NewSetData.Name[1] = ""
				NewSetData.IsLevelSync[1] = LevelSyncSetByDefault
				ImGui.CloseCurrentPopup()
			end
		end

		ImGui.SameLine()

		if ImGui.Button("Cancel", { 120, 0 }) then
			ImGui.CloseCurrentPopup()
		end

		ImGui.EndPopup()
	end
end

---@return nil
-- Renders the options button and modal for editing an existing set
local function EditSet()
	-- If the selected set isn't empty show the options
	if State.SelectedSet ~= "" and State.SelectedSet ~= "None" then
		if ImGui.Button("Options") then
			-- Pre-fill the edit data with current values
			EditSetData.Name[1] = State.SelectedSet

			local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)

			EditSetData.IsLevelSync[1] = Set.LevelSyncSet

			ImGui.OpenPopup("EditSetPopup")
		end
	end

	if ImGui.BeginPopupModal("EditSetPopup", nil, ImGuiWindowFlags_AlwaysAutoResize) then
		ImGui.Text("Editing Set: " .. State.SelectedSet)
		ImGui.Separator()

		ImGui.Text("Rename:")
		ImGui.InputText("##edit_setname", EditSetData.Name, 64)

		ImGui.Checkbox("Level Sync", EditSetData.IsLevelSync)

		ImGui.Separator()

		-- CONFIRM / SAVE
		if ImGui.Button("Save Changes", { 120, 0 }) then
			local OldName = State.SelectedSet
			local NewName = EditSetData.Name[1]

			-- 1. Handle Rename
			if OldName ~= NewName then
				SetManager.RenameSet(State.SelectedJob, OldName, NewName)
				State.SelectedSet = NewName
			end

			-- 2. Handle LevelSync Toggle if it changed
			local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)

			if Set.LevelSyncSet ~= EditSetData.IsLevelSync[1] then
				SetManager.ToggleLevelSync(State.SelectedJob, State.SelectedSet)
			end

			ImGui.CloseCurrentPopup()
		end

		ImGui.SameLine()

		-- DELETE
		ImGui.PushStyleColor(ImGuiCol_Button, { 0.6, 0.1, 0.1, 1.0 }) -- Red for danger
		if ImGui.Button("Delete Set", { 120, 0 }) then
			SetManager.DeleteSet(State.SelectedJob, State.SelectedSet)
			State.SelectedSet = "None" -- Reset selection
			ImGui.CloseCurrentPopup()
		end
		ImGui.PopStyleColor()

		if ImGui.Button("Cancel", { 248, 0 }) then
			ImGui.CloseCurrentPopup()
		end

		ImGui.EndPopup()
	end
end

local ExportText = { "" }

---@return nil
-- Renders the export button and modal for generating Luashitacast code
local function ExportSet()
	if State.SelectedSet ~= "" and State.SelectedSet ~= "None" then
		if ImGui.Button("Export") then
			-- We pass the internal 'Sets' table from your SetManager
			-- You might need a Module.GetFullTable() in SetManager to access it
			ExportText[1] = Exporter.ExportJobSets()
			ImGui.OpenPopup("ExportOutput")
		end
	end

	-- THE EXPORT MODAL
	if ImGui.BeginPopupModal("ExportOutput", nil, ImGuiWindowFlags_NoResize) then
		ImGui.Text("Exported Code:")
		ImGui.Separator()

		if ImGui.Button("Copy to Clipboard", { 500, 0 }) then
			-- This Ashita/ImGui function pushes the string to your OS clipboard
			ImGui.SetClipboardText(ExportText[1])
			-- Optional: You could set a 'Copied!' status flag here to show a temporary message
		end

		-- Multi-line text box for easy copying
		ImGui.InputTextMultiline(
			"##export_code",
			ExportText,
			#ExportText[1] + 1024,
			{ 500, 300 },
			ImGuiInputTextFlags_ReadOnly
		)

		if ImGui.Button("Close", { 500, 0 }) then
			ImGui.CloseCurrentPopup()
		end
		ImGui.EndPopup()
	end
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
