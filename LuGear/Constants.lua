---@alias SlotName "Main"|"Sub"|"Range"|"Ammo"|"Head"|"Neck"|"Ear1"|"Ear2"|"Body"|"Hands"|"Ring1"|"Ring2"|"Back"|"Waist"|"Legs"|"Feet"
---@alias WeaponType "Hand-to-Hand"|"Dagger"|"Sword"|"Great Sword"|"Axe"|"Great Axe"|"Scythe"|"Polearm"|"Katana"|"Great Katana"|"Club"|"Staff"|"Archery"|"Marksmanship"|"Throwing"
---@alias JobName "GLOBAL"|"WAR"|"MNK"|"WHM"|"BLM"|"RDM"|"THF"|"PLD"|"DRK"|"BST"|"BRD"|"RNG"|"SAM"|"NIN"|"DRG"|"SMN"|"BLU"|"COR"|"PUP"|"DNC"|"SCH"|"GEO"|"RUN"
---@alias ItemType "Shield"|"Armor"|"Item"
---@alias Sets table<JobName, SetDefinitions>
---@alias SetDefinitions table<string, GearSet>
---@alias GearSet { LevelSyncSet: boolean, Slots: table<SlotName, SlotValue> }
---@alias SlotValue table<{ Name: string, Augments: table<string>? }>

local Module = {
	JobArray = {
		"GLOBAL",
		"WAR",
		"MNK",
		"WHM",
		"BLM",
		"RDM",
		"THF",
		"PLD",
		"DRK",
		"BST",
		"BRD",
		"RNG",
		"SAM",
		"NIN",
		"DRG",
		"SMN",
		"BLU",
		"COR",
		"PUP",
		"DNC",
		"SCH",
		"GEO",
		"RUN",
	},
}

return Module
