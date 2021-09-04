-- SHARE xray VISION
	if	not	markToggle	then
		return
	end
	if	inGame()	and	isPlaying()	and	not	inChat()	and	not	InOverlay()	then
		markToggle(true)
		beep()
	end