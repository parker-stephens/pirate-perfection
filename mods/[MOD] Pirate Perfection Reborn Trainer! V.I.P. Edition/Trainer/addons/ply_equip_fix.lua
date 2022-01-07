--Purpose: fixes case, where you attempt to interact with something, that needs deployable you don't have.
--Also it adds usefull method for developers
--Author: ThisJazzman

local PlayerManager = PlayerManager
local equipment_data_by_name = PlayerManager.equipment_data_by_name

local backuper = backuper
local hijack = backuper.hijack
local infinite_equipments = PlayerManager.infinite_equipments
if ( not infinite_equipments ) then
	infinite_equipments = {}
	PlayerManager.infinite_equipments = infinite_equipments
end
local all_blocked = false

--You can also pass 0 as equipment_id, which will result in all equipments being enabled depending on table or disabled.
local set_infinite = function( equipment_id, state )
	if ( equipment_id == 0 ) then
		all_blocked = state
	else
		infinite_equipments[equipment_id] = state
	end
end

PlayerManager.set_infinite_equipment = set_infinite

hijack(backuper, 'PlayerManager.remove_equipment',
	function(o, self, equipment_id, ...)
		if ( all_blocked or infinite_equipments[equipment_id] ) then
			--Instead of hustling with function hijacks it will just read table for equipments it don't need to remove
			return
		end
		local equipment, index = self:equipment_data_by_name(equipment_id)
		if ( equipment ) then
			return o(self, equipment_id, ...)
		end
	end
)

local all_specials_blocked = false
local infinite_specials = PlayerManager.infinite_specials
if ( not infinite_specials ) then
	infinite_specials = {}
	PlayerManager.infinite_specials = infinite_specials
end

local set_infinite_special = function( special_id, state )
	if ( special_id == 0 ) then
		all_specials_blocked = state
	else
		infinite_specials[special_id] = state
	end
end

PlayerManager.set_infinite_special = set_infinite_special

hijack(backuper, 'PlayerManager.remove_special',
	function( o, self, name, ... )
		if ( all_specials_blocked or infinite_specials[name] ) then
			return
		end
		return o(self, name, ...)
	end
)