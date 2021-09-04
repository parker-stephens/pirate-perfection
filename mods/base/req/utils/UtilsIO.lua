
function io.file_is_readable( fname )

	local file = io.open(fname, "r" )
	if file ~= nil then
		io.close(file)
		return true
	end

	return false

end

function io.remove_directory_and_files( path, verbose )

	vlog = function(str)
		if verbose then
			log(str)
		end
	end

	if not path then
		log("[Error] paramater #1 to io.remove_directory_and_files, string expected, recieved " .. tostring(path))
		return false
	end

	if not file.DirectoryExists( path ) then
		log("[Error] Directory does not exist: " .. path)
		return false
	end

	local dirs = file.GetDirectories( path )
	if dirs then
		for k, v in pairs( dirs ) do
			local child_path = path .. v .. "/"
			vlog("Removing directory: " .. child_path)
			io.remove_directory_and_files( child_path, verbose )
			local r = file.RemoveDirectory( child_path )
			if not r then
				log("[Error] Could not remove directory: " .. child_path)
				return false
			end
		end
	end

	local files = file.GetFiles( path )
	if files then
		for k, v in pairs( files ) do
			local file_path = path .. v
			vlog("Removing files: " .. file_path)
			local r, error_str = os.remove( file_path )
			if not r then
				log("[Error] Could not remove file: " .. file_path .. ", " .. error_str)
				return false
			end
		end
	end

	vlog("Removing directory: " .. path)
	local r = file.RemoveDirectory( path )
	if not r then
		log("[Error] Could not remove directory: " .. path)
		return false
	end

	return true

end

function io.save_as_json( data, path )

	local count = 0
	for k, v in pairs( data ) do
		count = count + 1
	end

	if data and count > 0 then

		local file = io.open(path, "w+")
		if file then
			file:write( json.encode( data ) )
			file:close()
			return true
		else
			log(string.format("[Error] Could not save to file '%s', data may be lost!", path))
			return false
		end

	else
		log(string.format("[Warning] Attempting to save empty data table to '%s', skipping...", path))
		return true
	end

end

function io.load_as_json( path )

	local file = io.open( path, "r" )
	if file then
		local file_contents = file:read("*all")
		file:close()
		return json.decode(file_contents)
	else
		log(string.format("[] Could not load file '%s', no data loaded...", path))
		return nil
	end

end
