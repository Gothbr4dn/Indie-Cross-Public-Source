function onCreate()
	if dadName == 'sans-nightmare' then
		makeAnimatedLuaSprite('animatedicon', 'UISansIcon_assets', getProperty('iconP2.x'), getProperty('iconP2.y'))
		addAnimationByPrefix('animatedicon', 'winning', 'win0', 24, true)
		addAnimationByPrefix('animatedicon', 'normal', 'normal0', 24, true)
		addAnimationByPrefix('animatedicon', 'losing', 'loss0', 24, true)
		setScrollFactor('animatedicon', 0, 0)
		setObjectCamera('animatedicon', 'hud')
                setObjectOrder('animatedicon', getObjectOrder("iconP2"))
		addLuaSprite('animatedicon', true)
		objectPlayAnimation('animatedicon', 'normal', false)
		setProperty('animatedicon.visible', false)
	end
end


function onUpdate(elapsed)
    if curStep >= 0 then
	setProperty('iconP2.alpha', 0)
	setProperty('animatedicon.visible', true)
	else
	setProperty('iconP2.alpha', 1)
	end
	if dadName == 'sans-nightmare' then
		if getProperty('health') < 0.20 then
			objectPlayAnimation('animatedicon', 'winning', false)
		end
		if getProperty('health') > 1.6 then
			objectPlayAnimation('animatedicon', 'losing', false)
		else
			objectPlayAnimation('animatedicon', 'normal', false)
		end
	end
	setProperty('camOther.zoom', getProperty('camHUD.zoom'))
	setProperty('animatedicon.x', getProperty('iconP2.x') + -20)
	setProperty('animatedicon.angle', getProperty('iconP2.angle'))
	setProperty('animatedicon.y', getProperty('iconP2.y') + -20)
	setProperty('animatedicon.scale.x', getProperty('iconP2.scale.x'))
	setProperty('animatedicon.scale.y', getProperty('iconP2.scale.y'))
end
