SplashScene = class
  constructor = function()
    this.alpha = 0
    this.phase = 0
    this.beginPhase(1)
    
    this.gmtkImageLoader = asset_manager.loadImage("gmtk_game_jam_2025_logo_white")
  end
  
  beginPhase = function(number)
    this.phase = number

    local fadeIn = global.tweenService.createTween(this, "alpha", 0, 1, 1, global.Easing.sineInOut)
    fadeIn.completionHandlerData = this
    fadeIn.completionHandler = function(data)
      data.alpha = 1
      
      local fadeOut = global.tweenService.createTween(data, "alpha", 1, 0, 3, global.Easing.sineInOut)
      fadeOut.completionHandlerData = data
      fadeOut.completionHandler = function(data)
        if data.phase == 1 then
          data.beginPhase(2)
          return
        end
        
        local transitionAction = function()
          global.currentScene = new MainMenuScene()
        end

        global.transition.requestTransition(transitionAction, false, 1)
      end
    end
  end
  
  update = function(deltaTime)
  end
  
  draw = function()
    screen.setAlpha(this.alpha)

    if this.phase == 1 then
      screen.drawSprite("plasmapuffs", 0, 20, 144, 144)
      screen.drawText("PlasmaPuffs Productions", 0, -50, 16, "white")
    else
      screen.drawText("Made in <96h for the...", 0, 50, 12, "white")
      screen.drawImage(this.gmtkImageLoader.image, 0, -10, 3840 / 20, 2160 / 20)
    end

    screen.resetAlpha()
  end
end

