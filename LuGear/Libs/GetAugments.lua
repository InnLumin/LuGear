local ResourceManager = AshitaCore:GetResourceManager()

local ItemData = require("Vendor.itemdata")

return function(item, ritem)
	if item == nil or ritem == nil then
		return false, "Error: Both item and ritem userdata must be provided."
	end

	-- Call the function directly from itemdata which uses the native game call
	local augments = ItemData.parse(item, ritem).augments

	if not augments or #augments == 0 then
		return false, "Unaugmented or Augment Parsing Failed."
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
