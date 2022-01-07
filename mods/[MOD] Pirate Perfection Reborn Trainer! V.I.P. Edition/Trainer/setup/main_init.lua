local ppr_dofile = ppr_dofile
--Hack lines
if (not orig__dofile) then
	orig__dofile = ppr_dofile
end
--End of hacks

ppr_dofile('Trainer/Setup/__require.lua') --Loading improved ppr_require function
__first_require_clbk =
function()
	ppr_dofile("Trainer/Setup/pre_init")
	--Write here code that needs to be executed on very first ppr_require.
end
print("Pirate Perfection Reborn Trainer! \nv2.0.0-V.I.P. Edition \nSuperBLT v3.1.2 (R026) \nby Baddog-11 \ninitialized")
--[[
--Callbacks, these executed before ppr_require script being executed
__require_pre[required_script] = callback_function

--Callbacks, these executed after required script being executed
__require_after[required_script] = callback_function2

--Callbacks, these will override whole ppr_require
__require_override[required_script] = callback_function3
]]

--Anything else, that needs to be executed on newstate goes here. Keep in mind, that only lua libs are opened at this stage, none of game internal classes, objects, methods are initialized yet.