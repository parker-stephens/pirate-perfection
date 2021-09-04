
Hooks:Register("DynamicResourceManagerCreated")
Hooks:PostHook(DynamicResourceManager, "init",
		"BLTDynamicResourceManagerCreated", function(self)
	Hooks:Call("DynamicResourceManagerCreated", self)
end)
