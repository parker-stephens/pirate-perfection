local old_init = WeaponTweakData.init

function WeaponTweakData:init(tweak_data)
	old_init(self, tweak_data)
	self.hk21.bipod_camera_spin_limit	=	10800
	self.hk21.bipod_camera_pitch_limit	=	10800
	self.m249.bipod_camera_spin_limit	=	10800
	self.m249.bipod_camera_pitch_limit	=	10800
	self.rpk.bipod_camera_spin_limit	=	10800
	self.rpk.bipod_camera_pitch_limit	=	10800
	self.mg42.bipod_camera_spin_limit	=	10800
	self.mg42.bipod_camera_pitch_limit	=	10800
	self.par.bipod_camera_spin_limit	=	10800
	self.par.bipod_camera_pitch_limit	=	10800
end

--Instant Bipod Deploy
local old_init = WeaponTweakData.init

function WeaponTweakData:init(tweak_data)
	old_init(self, tweak_data)
	self.hk21.timers.deploy_bipod	=	0
	self.m249.timers.deploy_bipod	=	0
	self.rpk.timers.deploy_bipod	=	0
	self.mg42.timers.deploy_bipod	=	0
	self.par.timers.deploy_bipod	=	0
end