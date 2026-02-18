local ImGui = require("imgui")

local DropdownStorage = {}

---@param label string -- Unique name for the dropdown
---@param options string[] -- A array of the options to give the user
---@param default_value? string | number -- A optional default value to start with
---@param on_callback function<string>
---@return string -- The selected option
return function(label, options, default_value, on_callback)
	if DropdownStorage[label] == nil then
		if type(default_value) == "number" and options[default_value] then
			DropdownStorage[label] = options[default_value]
		elseif type(default_value) == "string" then
			DropdownStorage[label] = default_value
		else
			DropdownStorage[label] = options[1]
		end
	end

	if ImGui.BeginCombo(label, DropdownStorage[label]) then
		for _, option in ipairs(options) do
			local IsSelected = DropdownStorage[label] == option

			if ImGui.Selectable(option, IsSelected) then
				DropdownStorage[label] = option

				if on_callback and type(on_callback) == "function" then
					on_callback(DropdownStorage[label])
				end
			end

			if IsSelected then
				ImGui.SetItemDefaultFocus()
			end
		end

		ImGui.EndCombo()
	end

	return DropdownStorage[label]
end
