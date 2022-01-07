-- Execute a Unit Sequence
local scripts = managers.mission:scripts()
for _, script in pairs( scripts ) do
    local elements = script:elements()
    for id, element in pairs( elements ) do
        local trigger_list = element:values().trigger_list or {}
        for _, trigger in pairs( trigger_list ) do
            if trigger.notify_unit_sequence == "*triggername*" then
                element:on_executed()
            end
        end
    end
end