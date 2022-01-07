--No invisible walls
--Author: Harfatus

local managers = managers
local M_network = managers.network
local net_session = M_network:session()

if ( net_session ) then
	local send_to_peers = net_session.send_to_peers
	local CollisionData = {
							["276de19dc5541f30"] = true,
							["29d0139549a54de7"] = true,

							["53a9a98f72835230"] = true,	--regular collisions

							["63be2c801283f573"] = true,
							["673cff4d49da2368"] = true,	--vehicle collisions(blocks players too)
							["673ea142d68175df"] = true,
							["6cdb4f6f58ec4fa8"] = true,

							["78f4407343b48f6d"] = true,
							["7a4c85917d8d8323"] = true,
							["7ae8fcbfe6a00f7b"] = true,

							["86efb80bf784046f"] = true,
							["8f3cb89b79b42ec4"] = true,

							["9d8b22836aa015ed"] = true,
							["9eda9e73ac0ef710"] = true,

							["b37a4188fde4c161"] = true,
							["c5c4442c5e147cb0"] = true,
							["e379cc9592197cd8"] = true,
							["e8fe662bb4d262d3"] = true,
						}
	for _,unit in pairs(World:find_units_quick("all", 1)) do
		if CollisionData[unit:name():key()] then
			send_to_peers(net_session, 'remove_unit', unit)
			unit:set_slot(0)
		end
	end  
end