
CloneClass( GameSetup )

Hooks:RegisterHook("GameSetupUpdate")
function GameSetup.update(this, t, dt)
	Hooks:Call("GameSetupUpdate", t, dt)
	return this.orig.update(this, t, dt)
end

Hooks:RegisterHook("GameSetupPausedUpdate")
function GameSetup.paused_update(this, t, dt)
	Hooks:Call("GameSetupPausedUpdate", t, dt)
	return this.orig.paused_update(this, t, dt)
end
