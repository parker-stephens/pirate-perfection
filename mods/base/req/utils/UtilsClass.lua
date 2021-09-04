
-- BLT Class definition, same as Payday 2 definition

BLT.__overrides = {}
BLT.__everyclass = {}

function blt_class(...)

	local super = (...)
	if select("#", ...) >= 1 and super == nil then
		error("trying to inherit from nil", 2)
	end
	local class_table = {}
	if BLT.__everyclass then
		table.insert(BLT.__everyclass, class_table)
	end
	class_table.super = BLT.__overrides[super] or super
	class_table.__index = class_table
	class_table.__module__ = getfenv(2)
	setmetatable(class_table, BLT.__overrides[super] or super)

	function class_table.new(klass, ...)
		local object = {}
		setmetatable(object, BLT.__overrides[class_table] or class_table)
		if object.init then
			return object, object:init(...)
		end
		return object
	end

	return class_table

end
