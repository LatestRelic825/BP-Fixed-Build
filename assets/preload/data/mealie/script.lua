local angleshit = 1;
local anglevar = 1;
function onBeatHit()
	if curBeat < 999999 then
		triggerEvent('Add Camera Zoom', 0,0)

		if curBeat % 2 == 0 then
			angleshit = anglevar;
		else
			angleshit = -anglevar;
		end
		setProperty('camHUD.angle',angleshit*0.05)
		setProperty('camGame.angle',angleshit*0.02)
		doTweenAngle('turn', 'camHUD', angleshit, stepCrochet*0.0005, 'circOut')
		doTweenX('tuin', 'camHUD', -angleshit*0.05, crochet*0.0003, 'linear')
		doTweenAngle('tt', 'camGame', angleshit, stepCrochet*0.0005, 'circOut')
		doTweenX('ttrn', 'camGame', -angleshit*0.02, crochet*0.0003, 'linear')
	else
		setProperty('camHUD.angle',0)
		setProperty('camHUD.x',0)
		setProperty('camHUD.x',0)
	end
		
end

function onStepHit()
	if curBeat < 99999 then -- luas culiaos
		if curStep % 4 == 0 then
			doTweenY('rrr', 'camHUD', -0.3, stepCrochet*0.0005, 'circOut')
			doTweenY('rtr', 'camGame.scroll', 0.1, stepCrochet*0.0003, 'sineIn')
		end
		if curStep % 4 == 2 then
			doTweenY('rir', 'camHUD', 0, stepCrochet*0.0005, 'sineIn')
			doTweenY('ryr', 'camGame.scroll', 0, stepCrochet*0.0003, 'sineIn')
		end
	end
end