local ResourceManager = AshitaCore:GetResourceManager()

local ItemData = require("Vendor.itemdata")

return function(item, ritem)
	if item == nil or ritem == nil then
		return ""
	end

	local augments = ItemData.parse(item, ritem).augments

	if not augments or #augments == 0 then
		return ""
	end

	local output = {}
	for _, Augment in ipairs(augments) do
		local RawAugment = ResourceManager:GetString("augments", Augment.index)
		if RawAugment and type(RawAugment) == "string" then
			table.insert(output, string.format(RawAugment, Augment.value))
		end
	end

	return table.concat(output, "")
end
