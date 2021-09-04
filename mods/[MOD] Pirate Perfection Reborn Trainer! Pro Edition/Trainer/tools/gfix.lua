--Puprose: fixes dumb behavior of _G

local g = getmetatable(_G)
g.__index = g

--New
g.__newindex = nil