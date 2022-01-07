--Purpose: secure any bag on any map
--Author: Simplity

--local is_client = is_client
local backuper = backuper
local insert = table.insert
local pairs = pairs
local World = World

local _project_instigators = backuper:backup("ElementAreaTrigger.project_instigators")
function ElementAreaTrigger:project_instigators()
	--[[if is_client() then
		return _project_instigators( self )
	end]]
	
	local instigators = _project_instigators( self )
	if self._values.instigator == "loot" or self._values.instigator == "unique_loot" then
		local all_found = World:find_units_quick("all", 14)

		for _, unit in pairs( all_found ) do
			local carry_data = unit:carry_data()
			if carry_data then
				insert(instigators, unit)
			end
		end
	end
	
	return instigators
end