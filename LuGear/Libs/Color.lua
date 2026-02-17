local BlackColor = { 0, 0, 0, 1 }
local WhiteColor = { 1, 1, 1, 1 }

local Module = {}

local function Lerp(a, b, t)
	return a + (b - a) * t
end

function Module.LerpColor(current, target, intensity)
	return {
		Lerp(current[1], target[1], intensity),
		Lerp(current[2], target[2], intensity),
		Lerp(current[3], target[3], intensity),
		Lerp(current[4], target[4], intensity),
	}
end

function Module.DarkenColor(color, intensity)
	return Module.LerpColor(color, BlackColor, intensity)
end

function Module.LightenColor(color, intensity)
	return Module.LerpColor(color, WhiteColor, intensity)
end

return Module
