-- CHINA PUFF TWEAKS
--	tweak_data.weapon.china = {}
--	tweak_data.weapon.china.category = "grenade_launcher"
--	tweak_data.weapon.china.upgrade_blocks = {weapon = {"clip_ammo_increase"}}
--	tweak_data.weapon.china.projectile_type_index = 27
--	tweak_data.weapon.china.projectile_type_indices = {launcher_incendiary = 28}
--	tweak_data.weapon.china.damage_melee = damage_melee_default
--	tweak_data.weapon.china.damage_melee_effect_mul = damage_melee_effect_multiplier_default
--	tweak_data.weapon.china.sounds = {}
--	tweak_data.weapon.china.sounds.fire = "china_fire"
--	tweak_data.weapon.china.sounds.dryfire = "shotgun_dryfire"
--	tweak_data.weapon.china.sounds.enter_steelsight = "secondary_steel_sight_enter"
--	tweak_data.weapon.china.sounds.leave_steelsight = "secondary_steel_sight_exit"
--	tweak_data.weapon.china.timers = {}
	tweak_data.weapon.china.timers.shotgun_reload_enter = 0.01
	tweak_data.weapon.china.timers.shotgun_reload_exit_empty = 0.01
	tweak_data.weapon.china.timers.shotgun_reload_exit_not_empty = 0.01
	tweak_data.weapon.china.timers.shotgun_reload_shell = 0.01
	tweak_data.weapon.china.timers.shotgun_reload_first_shell_offset = 0
	tweak_data.weapon.china.timers.unequip = 0.01
	tweak_data.weapon.china.timers.equip = 0.01
--	tweak_data.weapon.china.name_id = "Baddog-11's Real China Puff"
--	tweak_data.weapon.china.desc_id = "bm_w_china_desc"
--	tweak_data.weapon.china.description_id = "des_china"
--	tweak_data.weapon.china.muzzleflash = "effects/payday2/particles/weapons/762_auto_fps"
--	tweak_data.weapon.china.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
--	tweak_data.weapon.china.use_data = {}
--	tweak_data.weapon.china.use_data.selection_index = 1
--	tweak_data.weapon.china.use_data.align_place = "right_hand"
	tweak_data.weapon.china.DAMAGE = 10000
	tweak_data.weapon.china.damage_near = 10000
	tweak_data.weapon.china.damage_far = 10000
	tweak_data.weapon.china.rays = 50
	tweak_data.weapon.china.CLIP_AMMO_MAX = 100
	tweak_data.weapon.china.NR_CLIPS_MAX = 100
	tweak_data.weapon.china.AMMO_MAX = tweak_data.weapon.china.CLIP_AMMO_MAX * tweak_data.weapon.china.NR_CLIPS_MAX
	tweak_data.weapon.china.AMMO_PICKUP = {1.05, 1.65}
--	tweak_data.weapon.china.FIRE_MODE = "single"
--	tweak_data.weapon.china.fire_mode_data = {}
--	tweak_data.weapon.china.fire_mode_data.fire_rate = 1.2
--	tweak_data.weapon.china.single = {}
--	tweak_data.weapon.china.single.fire_rate = 1.2
--	tweak_data.weapon.china.spread = {}
--	tweak_data.weapon.china.spread.standing = tweak_data.weapon.r870.spread.standing
--	tweak_data.weapon.china.spread.crouching = tweak_data.weapon.r870.spread.crouching
--	tweak_data.weapon.china.spread.steelsight = tweak_data.weapon.r870.spread.steelsight
--	tweak_data.weapon.china.spread.moving_standing = tweak_data.weapon.r870.spread.moving_standing
--	tweak_data.weapon.china.spread.moving_crouching = tweak_data.weapon.r870.spread.moving_crouching
--	tweak_data.weapon.china.spread.moving_steelsight = tweak_data.weapon.r870.spread.moving_steelsight
--	tweak_data.weapon.china.kick = {}
	tweak_data.weapon.china.kick.standing = {
		0.01,
		0.01,
		0.01,
		0.01
	}
--	tweak_data.weapon.china.kick.crouching = tweak_data.weapon.china.kick.standing
--	tweak_data.weapon.china.kick.steelsight = tweak_data.weapon.china.kick.standing
--	tweak_data.weapon.china.crosshair = {}
--	tweak_data.weapon.china.crosshair.standing = {}
--	tweak_data.weapon.china.crosshair.crouching = {}
--	tweak_data.weapon.china.crosshair.steelsight = {}
	tweak_data.weapon.china.crosshair.standing.offset = 0.16
	tweak_data.weapon.china.crosshair.standing.moving_offset = 0.8
	tweak_data.weapon.china.crosshair.standing.kick_offset = 0.6
--	tweak_data.weapon.china.crosshair.standing.hidden = true
	tweak_data.weapon.china.crosshair.crouching.offset = 0.08
	tweak_data.weapon.china.crosshair.crouching.moving_offset = 0.7
	tweak_data.weapon.china.crosshair.crouching.kick_offset = 0.4
--	tweak_data.weapon.china.crosshair.crouching.hidden = true
--	tweak_data.weapon.china.crosshair.steelsight.hidden = true
	tweak_data.weapon.china.crosshair.steelsight.offset = 0
	tweak_data.weapon.china.crosshair.steelsight.moving_offset = 0
	tweak_data.weapon.china.crosshair.steelsight.kick_offset = 0.1
--	tweak_data.weapon.china.shake = {}
	tweak_data.weapon.china.shake.fire_multiplier = 2
	tweak_data.weapon.china.shake.fire_steelsight_multiplier = 2
--	tweak_data.weapon.china.autohit = autohit_shotgun_default
--	tweak_data.weapon.china.aim_assist = aim_assist_shotgun_default
--	tweak_data.weapon.china.animations = {}
--	tweak_data.weapon.china.animations.equip_id = "equip_china"
--	tweak_data.weapon.china.animations.recoil_steelsight = true
--	tweak_data.weapon.china.global_value = "pal"
--	tweak_data.weapon.china.texture_bundle_folder = "lupus"
	tweak_data.weapon.china.panic_suppression_chance = 0.2
--	tweak_data.weapon.china.ignore_damage_upgrades = true
	tweak_data.weapon.china.stats = {
		damage = 210,
		spread = 26,
		recoil = 26,
		spread_moving = 26,
		zoom = 10,
		concealment = 30,
		suppression = 20,
		alert_size = 20,
		extra_ammo = 56,
		total_ammo_mod = 20,
		value = 10,
		reload = 21
	}
	tweak_data.weapon.china.stats_modifiers = {damage = 100}