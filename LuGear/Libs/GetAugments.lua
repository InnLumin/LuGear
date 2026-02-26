local ResourceManager = AshitaCore:GetResourceManager()

local ItemData = require("Vendor.itemdata")

---Handles parsing augments and returning as a string
---@param item item_t
---@param ritem IItem
return function(item, ritem)
	if item == nil or ritem == nil then
		return ""
	end

	local Augments = ItemData.parse_augments(item, ritem)

	if not Augments or #Augments == 0 then
		return ""
	end

	local output = {}
	for _, augment in ipairs(Augments) do
		local RawAugment = ResourceManager:GetString("augments", augment.index)

		if RawAugment and type(RawAugment) == "string" then
			-- Try with two values
			local Success, Result = pcall(string.format, RawAugment, augment.value, augment.value)

			-- Try with one value if two failed
			if not Success then
				Success, Result = pcall(string.format, RawAugment, augment.value)
			end

			-- If either succeed insert the result in the output
			if Success then
				table.insert(output, Result)
			end
		end
	end

	return table.concat(output, "")
end
