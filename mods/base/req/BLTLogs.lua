
BLTLogs = blt_class(BLTModule)
BLTLogs.__type = "BLTLogs"

function BLTLogs:init()

	BLTLogs.super.init(self)

	self.logs_location = "mods/logs/"
	self.logs_lifetime = {
		[1] = { 1, "blt_logs_one_day" },
		[2] = { 3, "blt_logs_three_days" },
		[3] = { 7, "blt_logs_one_week" },
		[4] = { 14, "blt_logs_two_weeks" },
		[5] = { 30, "blt_logs_thirty_days" },
	}
	self.day_length = 86400

end

function BLTLogs:LogNameToNumber( name )
	local strs = string.blt_split(name, "_")
	if #strs < 3 then
		return -1
	end
	return Utils:TimestampToEpoch( tonumber(strs[1]), tonumber(strs[2]), tonumber(strs[3]) )
end

function BLTLogs:CleanLogs( lifetime )

	lifetime = lifetime or 1

	print(string.format("[BLT] Cleaning logs folder, lifetime %i day(s)", lifetime))

	local current_time = os.time()
	local files = file.GetFiles( self.logs_location )
	if files then
		for i, file_name in pairs( files ) do

			local file_date = self:LogNameToNumber(file_name)
			if file_date > 0 and file_date < current_time - (lifetime * self.day_length) then
				print("[BLT] Removing log:", file_name)
				os.remove( string.format("%s%s", self.logs_location, file_name) )
			end

		end
	end

end
