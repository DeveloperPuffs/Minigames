global.loadFonts = function()
  screen.defaultFont = "Unbalanced"
  
  local fonts = [screen.defaultFont]
  if global.DEBUG_MODE then
    fonts.push("EnterCommand")
  end

  for font in fonts
    screen.loadFont(font)
  end
  
  while true
    local ready = true
    for font in fonts
      if not screen.isFontReady(font) then
        ready = false
        break
      end
    end
    
    if ready then
      break
    end
    
    sleep 1
  end
end

global.init = function()
  screen.init()
  global.loadFonts()

  global.currentTime = system.time() / 1000
  
  global.tweenService = new TweenService()
  global.transition = new Transition()
  
  global.musicName = ""
  global.musicHandle = false
  global.graphicsMode = global.GRAPHICS_MEDIUM
  
  debug.active = global.DEBUG_MODE
  debug.active_drawing = global.DEBUG_MODE
  debug.display_as_table = true
  debug.text_font = "EnterCommand"
  debug.text_font_size = 12
  debug.manual_input = true

  global.currentScene = new SplashScene()
end

global.requestMusic = function(name, volume)
  if global.musicName != name then
    if global.musicHandle then
      global.musicHandle.stop()
    end
    
    global.musicName = name
    global.musicHandle = audio.playMusic(global.musicName, volume, true)
    global.musicHandle.setPosition(0)
  end
end

global.update = function()
  local nextTime = system.time() / 1000
  local deltaTime = nextTime - global.currentTime
  global.currentTime = nextTime
  
  debug.update()
  debug.print("Font", debug.text_font)
  debug.print("FPS", system.fps)
  debug.print("Delta Time", deltaTime, 3)
  
  local graphicsModeText = ["Low", "Medium", "High"][global.graphicsMode]
  debug.print("Graphics Mode", graphicsModeText)
  
  global.tweenService.update(deltaTime)
  global.currentScene.update(deltaTime)
end

global.draw = function()
  screen.clear("black")
  
  global.currentScene.draw()
  global.transition.draw()
  debug.draw()
end