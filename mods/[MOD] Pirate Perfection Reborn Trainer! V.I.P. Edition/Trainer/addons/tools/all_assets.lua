-- Unlock all assets
-- Author: Simplity

local managers = managers

local M_assets = managers.assets
local unlock_asset = M_assets.unlock_asset

local session = managers.network:session()
local send_to_host = session.send_to_host
local is_server = Network:is_server()

for _,asset_id in pairs(M_assets:get_all_asset_ids( true )) do
	if is_server then
		unlock_asset( M_assets, asset_id )
	else
		send_to_host( session, "server_unlock_asset", asset_id )
	end
end