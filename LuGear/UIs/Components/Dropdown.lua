local ImGui = require("imgui")

local Values = {}
local LastSeenValues = {}

-- -@param label string -- Unique name for the dropdown
-- -@param options string[] -- A array of the options to give the user
-- -@param default_value? string | number -- A optional default value to start with
-- -@param on_callback function<string>
-- -@return string -- The selected option

---@param label string Unique ID
---@param config {Options: string[], Value?: string, Default?: string|number, Activated?: function}
return function(label, config)
	config = config or {}

	if config.Value ~= nil and config.Value ~= LastSeenValues[label] then
		Values[label] = config.Value
		LastSeenValues[label] = config.Value
	elseif Values[label] == nil then
		local Start = type(config.default) == "number" and config.Options[config.default] or config.default
		Values[label] = Start or config.Options[1] or "None"
	end

	local CurrentValue = Values[label]
	if ImGui.BeginCombo(label, CurrentValue) then
		for _, option in ipairs(config.Options) do
			local IsSelected = CurrentValue == option

			if ImGui.Selectable(option, IsSelected) then
				CurrentValue = option

				if config.Activated and type(config.Activated) == "function" then
					config.Activated(CurrentValue)
				end
			end

			if IsSelected then
				ImGui.SetItemDefaultFocus()
			end
		end

		ImGui.EndCombo()
	end

	return CurrentValue
end
