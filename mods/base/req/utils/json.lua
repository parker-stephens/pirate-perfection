
_G.json = {}

function json.decode( data )

	-- Attempt to use 1.0 json module first 
	local value = nil
	local passed = pcall(function()
		value = json10.decode( data )
	end)
	if not passed then
		-- If it fails, then try using the old json module to load malformatted json files
		log(string.format("Found a json error, attempting to use old json loader!"))
		value = json09.decode( data )
	end

	return value

end

function json.encode( data )
	return json10.encode( data )
end
