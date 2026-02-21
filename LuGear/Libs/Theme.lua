local Module = {}

-- Default red: 0.83, 0.33, 0.28, 0.78
Module.Default = {
	Colors = {
		Inactive = { 0.25, 0.25, 0.25, 0.60 },
		Active = { 0.40, 1.00, 0.50, 1.0 },
		Hover = { 0.92, 0.45, 0.45, 0.50 },
	},
}

Module.SelectedTheme = Module.Default

return Module
