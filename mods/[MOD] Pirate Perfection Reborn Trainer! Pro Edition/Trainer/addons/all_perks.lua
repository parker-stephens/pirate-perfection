-- Use all perks at once , excluding Negative Perks
for _, specialization in pairs( tweak_data.skilltree.specializations ) do
	for _, tree in pairs( specialization ) do
		if tree.upgrades then
			for _, upgrade in ipairs( tree.upgrades ) do
--				if ( (not upgrade:find("loss")) and (not upgrade:find("penalty")) ) then -- Removes Negative Perks
					managers.upgrades:aquire( upgrade,false )
--				end
			end
		end
	end
end