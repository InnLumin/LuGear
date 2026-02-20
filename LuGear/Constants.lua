---@alias SlotName "Main"|"Sub"|"Range"|"Ammo"|"Head"|"Neck"|"Ear1"|"Ear2"|"Body"|"Hands"|"Ring1"|"Ring2"|"Back"|"Waist"|"Legs"|"Feet"
---@alias JobName "GLOBAL"|"WAR"|"MNK"|"WHM"|"BLM"|"RDM"|"THF"|"PLD"|"DRK"|"BST"|"BRD"|"RNG"|"SAM"|"NIN"|"DRG"|"SMN"|"BLU"|"COR"|"PUP"|"DNC"|"SCH"|"GEO"|"RUN"
---@alias ItemType "Shield"|"Armor"|"Item"|"Hand-to-Hand"|"Dagger"|"Sword"|"Great Sword"|"Axe"|"Great Axe"|"Scythe"|"Polearm"|"Katana"|"Great Katana"|"Club"|"Staff"|"Archery"|"Marksmanship"|"Throwing"|"Main"|"Sub"|"Ranged"|"Ammo"|"Head"|"Neck"|"Earring"|"Body"|"Hands"|"Ring"|"Back"|"Waist"|"Legs"|"Feet"
-- // ---@alias WeaponType "Hand-to-Hand"|"Dagger"|"Sword"|"Great Sword"|"Axe"|"Great Axe"|"Scythe"|"Polearm"|"Katana"|"Great Katana"|"Club"|"Staff"|"Archery"|"Marksmanship"|"Throwing"

---@alias Sets table<JobName, SetDefinitions>
---@alias SetDefinitions table<string, GearSet>
---@alias GearSet { LevelSyncSet: boolean, Slots: table<SlotName, SlotValue[]> }
---@alias SlotValue { Name: string, Augments: string }

---@class Item
---@field Name string
---@field Augments string
---@field Description string
---@field Type ItemType
---@field Level number
---@field Id string

---@type Sets
-- local Sets = {
-- 	DRG = {
-- 		Engaged = {
-- 			LevelSyncSet = false,
-- 			Slots = {
-- 				Body = {
-- 					{ Name = "Aries Chestpiece", Augments = "Accuracy+10 Attack+10" },
-- 				},
-- 			},
-- 		},
-- 	},
-- }

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
