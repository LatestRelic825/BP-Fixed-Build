local w = 0.0
local w1 = 0.0
local w2 = 0.0
local w3 = 0.0

local resizeX = 1280
local resizeY = 720

function resize()
    resizeWindow(resizeX,resizeY)
end

function start (song)
    useDownscroll(false)
	w = getScreenWidth()
	w1 = (w / 4) * 2 + (getWindowWidth() / 2) + 100
	w2 = w / -2.5
	w3 = (w / 1000) * 1.45
	setWindowPos((getScreenWidth() / 2 - getWindowWidth() / 2),  (getScreenHeight() / 2 - getWindowHeight() / 2))
    initBackgroundVideo("careless")
    for i = 0, 7 do 
        setActorX(1300, i)
    end
    showOnlyStrums = true
    setActorAlpha(0,'boyfriend')
    resize()
end


function setDefault(id)
	_G['defaultStrum'..id..'X'] = getActorX(id)
end


function songStart()
    for i = 0, 3 do
        if getActorAlpha(i) ~= 0 then 
            setActorAlpha(0,i)
        end
    end
    for i = 4, 7 do -- go to the center
        tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 275,getActorAngle(i) + 360, 4, 'setDefault')
    end
    tweenFadeIn('boyfriend',1,4)
end

local defaultHudX = 0
local defaultHudY = 0

local defaultWindowX = 0
local defaultWindowY = 0

local moveWindow = false


local xTo4 = 0
local xTo5 = 0
local xTo6 = 0
local bfX = 0


local xTo7 = 0


function defaultWindow()
    setHudPosition(defaultHudX,defaultHudY)
    setWindowPos((getScreenWidth() / 2 - getWindowWidth() / 2),  (getScreenHeight() / 2 - getWindowHeight() / 2))
    setHudAngle(0)
end

function update (elapsed) 
    local currentBeat = (songPos / 1000)*(bpm/60)

    if moveWindow then
        setHudPosition(defaultHudX + 64 * math.sin((currentBeat * 0.35) * math.pi), defaultHudY + 64 * math.cos((currentBeat * 0.35) * math.pi))
        setWindowPos(defaultWindowX + 64 * math.sin((currentBeat * 0.35) * math.pi), defaultWindowY + 64 * math.cos((currentBeat * 0.35) * math.pi))
    else 
        setWindowPos((getScreenWidth() / 2 - getWindowWidth() / 2),  (getScreenHeight() / 2 - getWindowHeight() / 2))
    end
end


function beatHit (beat)

end



function bumpArrows()

    setActorX(xTo4, 4)
    tweenPos(4,xTo4 + 120,getActorY(4),0.5)
    setActorX(xTo5, 5)
    tweenPos(5,xTo5 + 60,getActorY(5),0.5)

    setActorX(xTo6, 6)
    tweenPos(6,xTo6 - 60,getActorY(6),0.5)
    setActorX(xTo7, 7)
    tweenPos(7,xTo7 - 120, getActorY(7),0.5)
end

local startBumping = false


local lastStep = 0

function stepHit (step)
    if lastStep ~= step then
        lastStep = step
        if step == 53 then

            for i = 0, 3 do
                if getActorAlpha(i) ~= 0 then 
                    setActorAlpha(0,i)
                end
            end

            defaultWindowX = getWindowX()
            defaultWindowY = getWindowY()

            xTo4 = getActorX(4) - 120
            xTo5 = getActorX(5) - 60
            xTo6 = getActorX(6) + 60
            xTo7 = getActorX(7) + 120

            defaultHudX = getHudX()
            defaultHudY = getHudY()

            bfX = getActorX('boyfriend')
        
            print("set values " .. xTo4 .. " "  .. xTo5 .. " "  .. xTo6 .. " "  .. xTo7)

            for i = 4, 7 do 
                tweenFadeIn(i,0,0.05)
            end
            tweenFadeIn('boyfriend',0,0.05)
        end

        if step == 62 then
            for i = 4, 7 do 
                tweenFadeIn(i,1,0.05)
            end
            tweenFadeIn('boyfriend',1,0.05)
        end

        if step == 109 then
            startBumping = true
        end

        if step == 159 then
            startBumping = false
        end
        
        if step == 445 then
            startBumping = true
        end

        if step == 450 then
            startBumping = false
        end

        if step == 525 then
            startBumping = false
        end

        if step == 687 then
            startBumping = false
        end

        if step == 825 then
            startBumping = true
        end


        if step == 285 then
            useDownscroll(false)
            camHudAngle = 0
            setActorX(bfX, 'boyfriend');
            setHudPosition(defaultHudX,defaultHudY - 45)
        end

        if step >= 825 then
            if startBumping and step % 16 == 9 then
                bumpArrows()
            end
        else
            if startBumping and step % 16 == 13 then
                bumpArrows()
            end
        end
    end

    if step == 165 then
        camHudAngle = 45
        setActorX(bfX + 100, 'boyfriend');
    end

    if step == 170 then
        camHudAngle = 85
        setActorX(bfX + 200, 'boyfriend');
    end

    if step == 177 then
        camHudAngle = 125
        setActorX(bfX - 100, 'boyfriend');
    end

    if step == 182 then
        camHudAngle = 150
        setActorX(bfX + 600, 'boyfriend');
    end

    if step == 189 then
        startBumping = true
        camHudAngle = 0
        useDownscroll(true)
        setActorX(bfX, 'boyfriend');
    end

    
    if step == 277 then
        camHudAngle = -45
        setActorX(bfX - 100, 'boyfriend');
    end

    if step == 279 then
        camHudAngle = -65
        setActorX(bfX + 200, 'boyfriend');
    end

    if step == 282 then
        camHudAngle = -125
        setActorX(bfX + 100, 'boyfriend');
    end


    if step == 315 then
        tweenHudAngle(0,0.4)
        tweenHudZoom(0.6,0.4)
        tweenHudPos(defaultHudX, defaultHudY, 0.4)
    end

    if step == 325 then
        print('moving window')
        moveWindow = true
    end

    if step == 437 then
        moveWindow = false
        defaultWindow()
        for i = 4, 7 do 
            tweenFadeIn(i,0,0.3)
        end
        tweenHudZoom(1,0.4)
        tweenHudPos(defaultHudX,defaultHudY,0.4)
        tweenFadeIn('boyfriend',0,0.3)
    end

    if step == 445 then
        print('resizing to ' .. getScreenWidth() .. 'x' .. getScreenHeight())
        resizeY = getScreenHeight()
        resizeX = getScreenWidth()
        resize()
    end

    if step == 447 then
        for i = 4, 7 do 
            tweenFadeIn(i,1,0.1)
        end
        tweenFadeIn('boyfriend',1,0.1)
    end

    if step == 509 then
        resizeX = 1280
        resizeY = 720
        resize()
    end


    if step == 597 then 
        tweenHudAngle(5,0.4)
        tweenHudPos(getHudX() + 35, getHudY() + 165, 0.4)
    end

    if step == 615 then 
        tweenHudAngle(-10,0.4)
        tweenHudPos(getHudX() - 125, getHudY() + 90, 0.4)
    end

    if step == 637 then
        tweenHudPos(defaultHudX,defaultHudY,0.4)
        tweenHudAngle(0,0.4)
    end

    if step == 698 then
        tweenHudPos(defaultHudX,defaultHudY,0.4)
        tweenFadeIn('boyfriend',0,0.3)
        resizeX = getScreenWidth()
        resizeY = getScreenHeight()
        resize()
    end

    if step == 710 then
        for i = 4, 7 do 
            tweenFadeIn(i,1,1)
        end
        tweenFadeIn('boyfriend',1,0.3)
    end

    
    if step == 774 then
        tweenFadeIn('boyfriend',0,0.5)
    end

    if step == 797 then
        tweenFadeIn('boyfriend',1,0.5)
    end

    if step == 809 then
        resizeX = 1280
        resizeY = 720
        resize()
        tweenHudZoom(0.6,0.4)
        tweenFadeIn('boyfriend',0,1)
    end

    if step == 877 then
        print('moving window')
        moveWindow = true
    end

    if step == 1072 then
        startBumping = false
        moveWindow = false
        defaultWindow()
        tweenHudZoom(1,0.4)
        tweenHudPos(defaultHudX,defaultHudY,0.4)
        showOnlyStrums = false
    end
end

function keyPressed (key)

end