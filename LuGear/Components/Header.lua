local ImGui = require("imgui")
local State = require("State")
local Constants = require("Constants")
local SetManager = require("Libs.SetManager")
local Exporter = require("Libs.Exporter")
local Popup = require("Components.Popup")
local Dropdown = require("Components.Dropdown")
local ItemSystem = require("Libs.ItemSystem")
local UIUtil = require("Libs.UIUtil")
local Theme = require("Libs.Theme")

local LevelSyncSetByDefault = State.UserSettings.GlobalConfig.LevelSyncSetByDefault

local ButtonPadding = 10

local function GetButtonSize(text)
	return { UIUtil.AddPaddingToText(text, ButtonPadding), 0 }
end

-- Renders the job selection combo box
local function JobSelection()
	ImGui.AlignTextToFramePadding()
	ImGui.Text("Job:")
	ImGui.SameLine()

	ImGui.SetNextItemWidth(90)

	Dropdown("##JobsDropdown", {
		Options = Constants.Jobs,
		Value = State.SelectedJob,
		Activated = function(selected_option)
			State.SelectedJob = selected_option
			State.SelectedSlot = "None"
			State.SelectedSet = "None"
		end,
	})
end

-- Renders the set selection combo box for the current job
local function SetSelection()
	ImGui.AlignTextToFramePadding()
	ImGui.Text("Set:")
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
		end,
	})
end

local NewSetName = { "" }
local NewSetLevelSync = { LevelSyncSetByDefault }
local NewSetSize = { 248, 0 }
local NewSetPopup, ToggleNewSetPopup = Popup("New Set##NewSetPopup", NewSetSize)

-- Renders the button and modal for creating a new gear set
local function NewSet()
	local ButtonLabel = "New"

	if ImGui.Button(ButtonLabel, GetButtonSize(ButtonLabel)) then
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
-- Renders the options button and modal for editing an existing set
local function EditSet()
	if State.SelectedSet == "" or State.SelectedSet == "None" then
		return
	end

	local ButtonLabel = "Edit"

	if ImGui.Button(ButtonLabel, GetButtonSize(ButtonLabel)) then
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
local ExportOpen = { false }
local ExportInitSize = { false }
local ExportCopiedTime = 0
local ExportButtonSize = { 240, 0 }
local ExportDefaultSize = { 1200, 520 }
local ExportWindowFlags = ImGuiWindowFlags_NoCollapse

local function ExportSet()
	local Set = SetManager.GetSet(State.SelectedJob, State.SelectedSet)

	if not Set or State.SelectedSet == "" or State.SelectedSet == "None" then
		return
	end

	if ImGui.Button("Export", GetButtonSize("Export")) then
		ExportText[1] = Exporter.ExportSet(Set, State.SelectedSet)
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

			if ImGui.BeginChild("##export_editor_host", { 0, -40 }, true, ImGuiWindowFlags_HorizontalScrollbar) then
				ImGui.InputTextMultiline(
					"##export_code",
					ExportText,
					math.max(#ExportText[1] + 1024, 8192),
					{ -1, -1 },
					ImGuiInputTextFlags_ReadOnly
				)
				ImGui.EndChild()
			end

			local IsCopied = (os.clock() - ExportCopiedTime) < 2
			local CopyLabel = IsCopied and "Copied!" or "Copy to Clipboard"

			if IsCopied then
				ImGui.PushStyleColor(ImGuiCol_Button, Theme.SelectedTheme.Colors.Inactive)
				ImGui.PushStyleColor(ImGuiCol_ButtonHovered, Theme.SelectedTheme.Colors.Inactive)
				ImGui.PushStyleColor(ImGuiCol_ButtonActive, Theme.SelectedTheme.Colors.Inactive)
			end

			if ImGui.Button(CopyLabel, ExportButtonSize) and not IsCopied then
				ImGui.SetClipboardText(ExportText[1])
				ExportCopiedTime = os.clock()
			end

			if IsCopied then
				ImGui.PopStyleColor(3)
			end

			ImGui.SameLine()
			if ImGui.Button("Close##Export", ExportButtonSize) then
				ExportOpen[1] = false
			end

			ImGui.End()
		end
	end
end

local ExportAllText = { "" }
local ExportAllOpen = { false }
local ExportAllInitSize = { false }
local ExportAllCopiedTime = 0

local function ExportAllSet()
	if ImGui.Button("Export All", GetButtonSize("Export All")) then
		ExportAllText[1] = Exporter.ExportJobSets()
		ExportAllOpen[1] = true
		ExportAllInitSize[1] = true
	end

	if ExportAllOpen[1] then
		if ExportAllInitSize[1] then
			ImGui.SetNextWindowSize(ExportDefaultSize, ImGui.ImGuiCond_Always)
		end

		if ImGui.Begin("Export All##HeaderExportAll", ExportAllOpen, ExportWindowFlags) then
			ExportAllInitSize[1] = false

			ImGui.TextDisabled("Resize this window if you need more room.")
			ImGui.Separator()

			if ImGui.BeginChild("##export_all_editor_host", { 0, -40 }, true, ImGuiWindowFlags_HorizontalScrollbar) then
				ImGui.InputTextMultiline(
					"##export_code_all",
					ExportAllText,
					math.max(#ExportAllText[1] + 1024, 8192),
					{ -1, -1 },
					ImGuiInputTextFlags_ReadOnly
				)
				ImGui.EndChild()
			end

			local IsCopied = (os.clock() - ExportAllCopiedTime) < 2
			local CopyLabel = IsCopied and "Copied!" or "Copy to Clipboard"

			if IsCopied then
				ImGui.PushStyleColor(ImGuiCol_Button, Theme.SelectedTheme.Colors.Inactive)
				ImGui.PushStyleColor(ImGuiCol_ButtonHovered, Theme.SelectedTheme.Colors.Inactive)
				ImGui.PushStyleColor(ImGuiCol_ButtonActive, Theme.SelectedTheme.Colors.Inactive)
			end

			if ImGui.Button(CopyLabel, ExportButtonSize) and not IsCopied then
				ImGui.SetClipboardText(ExportAllText[1])
				ExportAllCopiedTime = os.clock()
			end

			if IsCopied then
				ImGui.PopStyleColor(3)
			end

			ImGui.SameLine()
			if ImGui.Button("Close##ExportAll", ExportButtonSize) then
				ExportAllOpen[1] = false
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
		ImGui.SameLine()

		ExportAllSet()

		ImGui.EndChild()
	end
end
