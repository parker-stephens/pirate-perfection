if not SimpleMenu then
    SimpleMenu = class()

    function SimpleMenu:init(title, message, options)
        self.dialog_data = { title = title, text = message, button_list = {},
                             id = tostring(math.random(0,0xFFFFFFFF)) }
        self.visible = false
        for _,opt in ipairs(options) do
            local elem = {}
            elem.text = opt.text
            opt.data = opt.data or nil
            opt.callback = opt.callback or nil
            elem.callback_func = callback(self, self, "_do_callback",
                                          { data = opt.data,
                                            callback = opt.callback})
            elem.cancel_button = opt.is_cancel_button or false
            if opt.is_focused_button then
                self.dialog_data.focus_button = #self.dialog_data.button_list+1
            end
            table.insert(self.dialog_data.button_list, elem)
        end
        return self
    end

    function SimpleMenu:_do_callback(info)
        if info.callback then
            if info.data then
                info.callback(info.data)
            else
                info.callback()
            end
        end
        self.visible = false
    end

    function SimpleMenu:show()
        if self.visible then
            return
        end
        self.visible = true
        managers.system_menu:show(self.dialog_data)
    end

    function SimpleMenu:hide()
        if self.visible then
            managers.system_menu:close(self.dialog_data.id)
            self.visible = false
            return
        end
    end
end

patched_update_input = patched_update_input or function (self, t, dt )
    if self._data.no_buttons then
        return
    end
    
    local dir, move_time
    local move = self._controller:get_input_axis( "menu_move" )

    if( self._controller:get_input_bool( "menu_down" )) then
        dir = 1
    elseif( self._controller:get_input_bool( "menu_up" )) then
        dir = -1
    end
    
    if dir == nil then
        if move.y > self.MOVE_AXIS_LIMIT then
            dir = 1
        elseif move.y < -self.MOVE_AXIS_LIMIT then
            dir = -1
        end
    end

    if dir ~= nil then
        if( ( self._move_button_dir == dir ) and self._move_button_time and ( t < self._move_button_time + self.MOVE_AXIS_DELAY ) ) then
            move_time = self._move_button_time or t
        else
            self._panel_script:change_focus_button( dir )
            move_time = t
        end
    end

    self._move_button_dir = dir
    self._move_button_time = move_time
    
    local scroll = self._controller:get_input_axis( "menu_scroll" )
    -- local sdir
    if( scroll.y > self.MOVE_AXIS_LIMIT ) then
        self._panel_script:scroll_up()
        -- sdir = 1
    elseif( scroll.y < -self.MOVE_AXIS_LIMIT ) then
        self._panel_script:scroll_down()
        -- sdir = -1
    end
end
managers.system_menu.DIALOG_CLASS.update_input = patched_update_input
managers.system_menu.GENERIC_DIALOG_CLASS.update_input = patched_update_input

local function LoadItems(data)
    if managers.player:player_unit() then
        if data and data[2] ~= "armor" and data[2] ~= "masks" and data[2] ~= "melee" then
            local weapon = Global.blackmarket_manager.crafted_items[data[2]][data[1]]
            if weapon then
                managers.blackmarket:equip_weapon(data[2], data[1])
                managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
                managers.dyn_resource:load(Idstring("unit"), Idstring(tweak_data.weapon.factory[weapon.factory_id].unit), "packages/dyn_resources", false)
                managers.player:player_unit():inventory():add_unit_by_factory_name( weapon.factory_id, false, false, weapon.blueprint, weapon.texture_switches )
                return
            end
        elseif data then
            if data[2] == "armor" then
                managers.blackmarket:equip_armor(data[1])
            elseif data[2] == "masks" then
                managers.blackmarket:equip_mask(data[1])
            elseif data[2] == "melee" then
                managers.blackmarket:equip_melee_weapon(data[1])
            end
            managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
            managers.player:player_unit():_reload_outfit()
        end
        if data[2] == "masks" and alive(managers.player:local_player()) then
            -- call/do something to get mask off...PlayerMaskOFF maybe?
        end
    end
end

local function LoadOptions(type)
    local opts = {}
    local index = {}
    if type == "melee" then
        index = Global.blackmarket_manager[type .. "_weapons"]
    elseif type == "armors" then
        index = Global.blackmarket_manager[type]
    else
        index = Global.blackmarket_manager.crafted_items[type]
    end
    for i,v in pairs(index) do
        if v and type == "melee" then
            table.insert(opts, {
                text = managers.localization:text(tweak_data.blackmarket.melee_weapons[i].name_id),
                callback = LoadItems,
                data = {
                    i,
                    type
                }
            })
        elseif v and type == "armors" then
            table.insert(opts, {
                text = managers.localization:text(tweak_data.blackmarket.armors[i].name_id),
                callback = LoadItems,
                data = {
                    i,
                    "armor"
                }
            })
        elseif v and type == "secondaries" or type == "primaries" then
            table.insert(opts, {
                text = managers.blackmarket:get_weapon_name_by_category_slot(type,i):gsub("\"", ""),
                callback = LoadItems,
                data = {
                    i, 
                    type
                }
            })
        elseif v then
            table.insert(opts, {
                text = managers.blackmarket:get_mask_name_by_category_slot(type,i):gsub("\"", ""),
                callback = LoadItems,
                data = {
                    i,
                    type
                }
            })
        end
    end
    table.insert(opts, {
        text = "Close",
        is_cancel_button = true
    })
    ChangerMenu = SimpleMenu:new("Change Equipment", "Select the item you want", opts):show()
end

function NewRaycastWeaponBase:set_timer(timer, ...)
    NewRaycastWeaponBase.super.set_timer(self, timer)
    for _,data in ipairs(self._parts) do
        if ( data and data.unit ) then
            data.unit:set_timer(timer)
            data.unit:set_animation_timer(timer)
        end
    end
end

ChangerMenu = SimpleMenu:new("Change Equipment", "Select type of equipment to switch", {
    {
        text = "Change Primary",
        callback = LoadOptions,
        data = "primaries"
    },
    {
        text = "Change Secondary",
        callback = LoadOptions,
        data = "secondaries"
    },
    {
        text = "Change Armor",
        callback = LoadOptions,
        data = "armors"
    },
    {
        text = "Change Melee",
        callback = LoadOptions,
        data = "melee"
    },
    {
        text = "Change Mask",
        callback = LoadOptions,
        data = "masks"
    },
    {
        text = "Cancel",
        is_cancel_button = true
    }
}):show()