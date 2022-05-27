function onCreate()
  --background
  makeLuaSprite('bg','hall',-195,-70)
  makeLuaSprite('bg2','waterfall',-300,-175)
  scaleObject('bg2',1.3,1.3)
  scaleObject('bg',1.7,1.5)
  addLuaSprite('bg2',false)
  addLuaSprite('bg',false)
end