local defaultNotePos = {};
local defaultWinPos = {};
local spin = false;
local arrowMoveX = 14;
local arrowMoveY = 14;
local spin2 = false;
local window = false;

function onSongStart()
    for i = 0,7 do 
        x = getPropertyFromGroup('strumLineNotes', i, 'x')
        y = getPropertyFromGroup('strumLineNotes', i, 'y')
        table.insert(defaultNotePos, {x,y})
    end
end
function onUpdate(elapsed)
    songPos = getPropertyFromClass('Conductor', 'songPosition');
    currentBeat = (songPos / 10000) * (bpm / 60)
    if spin == true then 
        for i = 0,7 do 
			setPropertyFromClass('openfl.Lib','application.window.x', 160 * math.sin((currentBeat + i*32) * math.pi)+ 240)
			setPropertyFromClass('openfl.Lib','application.window.y', 30 * math.cos((currentBeat + i*32) * math.pi)+ 120)
        end
    end

    songPos = getPropertyFromClass('Conductor', 'songPosition');
    currentBeat = (songPos / 10000) * (bpm / 2)
    if spin2 == true then 
        for i = 0,7 do 
		setPropertyFromClass('openfl.Lib','application.window.x', 160 * math.sin((currentBeat / 4 + i*32) * math.pi)+ 240)
		setPropertyFromClass('openfl.Lib','application.window.y', 30 * math.cos((currentBeat / 4 + i*32) * math.pi)+ 120)
        end
    end

function onStepHit()

	if curStep == 16 then
		spin = true;
	end
    if curStep == 3968 then
		spin = false;
	end
    if curStep == 4096 then
		spin = true;
	end
    if curStep == 4224 then
		spin = false;
	end
    if curStep == 4352 then
		spin = true;
	end
    if curStep == 4736 then
		spin = false;
	end
    end
end