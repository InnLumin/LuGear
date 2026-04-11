local ImGui = require("imgui")
local State = require("State")
local Constants = require("Constants")
local FilterGear = require("Libs.FilterGear")
local SetManager = require("Libs.SetManager")
local Exporter = require("Libs.Exporter")
local Popup = require("Components.Popup")
local Dropdown = require("Components.Dropdown")

local LevelSyncSetByDefault = State.UserSettings.GlobalConfig.LevelSyncSetByDefault

---@return nil
local function JobSelection()
	ImGui.AlignTextToFramePadding()
	ImGui.Text("Job:")
	ImGui.SameLine()

	ImGui.SetNextItemWidth(90)

	Dropdown("##JobsDropdown", {
		Options = Constants.JobArray,
		Value = State.SelectedJob,
		Activated = function(selected_option)
			State.SelectedJob = selected_option
			State.SelectedSlot = "None"
			State.SelectedSet = "None"
		end,
	})
end

---@return nil
local function SetSelection()
	ImGui.AlignTextToFramePadding()
	ImGui.Text("Current Set:")
	ImGui.SameLine()
	ImGui.SetNextItemWidth(120)

	local Sets = SetManager.GetSets(State.SelectedJob)
	local SetsName = {}

	for Name, _ in pairs(Sets or {}) do
		table.insert(SetsName, Name)
	end

	Dropdown("##SetsDropdown", {
		Options = SetsName,
		Value = State.SelectedSet,
		Activated = function(selected_option)
			State.SelectedSet = selected_option
			if State.SelectedSlot ~= "" or State.SelectedSlot ~= "None" then
				FilterGear.UpdateFilteredGear(State.SelectedSlot)
			end
		end,
	})
end

local NewSetName = { "" }
local NewSetLevelSync = { LevelSyncSetByDefault }
local NewSetSize = { 248, 0 }
local NewSetPopup, ToggleNewSetPopup = Popup("New Set##NewSetPopup", NewSetSize)

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
local DrawEditPopup, ToggleEditPopup = Popup("Edit##HeaderEdit", EditSize)

---@return nil
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

		if ImGui.Button("Delete Set", { 120, 0 }) then
			SetManager.DeleteSet(State.SelectedJob, State.SelectedSet)
			ToggleEditPopup()
		end

		if ImGui.Button("Cancel", EditSize) then
			ToggleEditPopup()
		end
	end)
end

local ExportText = { "" }
local ExportOpen = { false }
local ExportInitSize = { false }
local ExportButtonSize = { 240, 0 }
local ExportDefaultSize = { 1200, 520 }
local ExportWindowFlags = ImGuiWindowFlags_NoCollapse

---@return nil
local function ExportSet()
	if State.SelectedSet == "" or State.SelectedSet == "None" then
		return
	end

	if ImGui.Button("Export##HeaderExportBtn") then
		ExportText[1] = Exporter.ExportJobSets()
		ExportOpen[1] = true
		ExportInitSize[1] = true
	end

	if ExportOpen[1] then
		if ExportInitSize[1] then
			ImGui.SetNextWindowSize(ExportDefaultSize, ImGui.ImGuiCond_Always)
		end

		if ImGui.Begin("Export##HeaderExport", ExportOpen, ExportWindowFlags) then
			ExportInitSize[1] = false

			ImGui.TextDisabled("Resize this window if you need more room.")
			ImGui.Separator()

			if ImGui.BeginChild("##export_editor_host", { 0, -70 }, true) then
				ImGui.InputTextMultiline(
					"##export_code",
					ExportText,
					math.max(#ExportText[1] + 1024, 8192),
					{ -1, -1 },
					ImGuiInputTextFlags_ReadOnly
				)
				ImGui.EndChild()
			end

			if ImGui.Button("Copy to Clipboard", ExportButtonSize) then
				ImGui.SetClipboardText(ExportText[1])
			end
			ImGui.SameLine()
			if ImGui.Button("Close", ExportButtonSize) then
				ExportOpen[1] = false
			end

			ImGui.End()
		end
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
