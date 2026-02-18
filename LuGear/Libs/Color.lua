local ImGui = require("imgui")

local BlackColor = { 0, 0, 0, 1 }
local WhiteColor = { 1, 1, 1, 1 }

local Module = {}

---Helper for Gamma Correction (sRGB to Linear)
---@param value number
---@return number
local function TransformValue(value)
	return value <= 0.03928 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
end

local function Lerp(a, b, t)
	return a + (b - a) * t
end

function Module.Lerp(current, target, intensity)
	return {
		Lerp(current[1], target[1], intensity),
		Lerp(current[2], target[2], intensity),
		Lerp(current[3], target[3], intensity),
		Lerp(current[4], target[4], intensity),
	}
end

---Calculates the True Relative Luminance [0-1]
---@param color table<number, number, number, number>
---@return number
function Module.GetLuminance(color)
	local Red = TransformValue(color[1])
	local Green = TransformValue(color[2])
	local Blue = TransformValue(color[3])

	return 0.2126 * Red + 0.7152 * Green + 0.0722 * Blue
end

---Gets the color Vec4 of a given ImGui ID
---@param idx number
---@return table<number, number, number, number>
function Module.GetColor(idx)
	return { ImGui.GetStyleColorVec4(idx) }
end

function Module.Darken(color, intensity)
	return Module.Lerp(color, BlackColor, intensity)
end

function Module.Lighten(color, intensity)
	return Module.Lerp(color, WhiteColor, intensity)
end

function Module.Saturate(color, intensity)
	local Luma = Module.GetLuminance(color)
	local Mutiplier = 1 + intensity

	return {
		math.min(1, Luma + (color[1] - Luma) * Mutiplier),
		math.min(1, Luma + (color[2] - Luma) * Mutiplier),
		math.min(1, Luma + (color[3] - Luma) * Mutiplier),
		color[4],
	}
end

function Module.Desaturate(color, percent)
	local Luma = Module.GetLuminance(color)
	local Mutiplier = 1 + intensity

	return {
		Luma + (color[1] - Luma) * Mutiplier,
		Luma + (color[2] - Luma) * Mutiplier,
		Luma + (color[3] - Luma) * Mutiplier,
		color[4],
	}
end

return Module
