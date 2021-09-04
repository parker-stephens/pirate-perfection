
BLTModule = blt_class()
BLTModule.__type = "BLTModule"

function BLTModule:init()
	print("[BLT] Loading module: ", self.__type)
end

function BLTModule:destroy()
end
