
global.IntroductionScene = class
  constructor = function(name)
    this.name = name
    
    this.alpha = 0
    
    local fadeIn = global.tweenService.createTween(
      this, "alpha", 0, 1, 1, global.Easing.sineInOut
    )
    
    fadeIn.completionHandler = function()
      global.sceneManager.scene.alpha = 1
      sleep 1 second
      
      local fadeOut = global.tweenService.createTween(
        global.sceneManager.scene, "alpha", 1, 0, 3, global.Easing.sineInOut  
      )
      
      fadeOut.completionHandler = function()
        local transition = function()
          audio.playMusic("menu", 0.5, true)
          global.sceneManager.setScene(global.SceneManager.MAIN_MENU)
        end
      
        global.transition.requestTransition(transition, function() end, 1)
      end
    end
  end
  
  update = function()
  end
  
  draw = function()
    screen.setAlpha(this.alpha)
    screen.drawSprite("pixelpuff", 0, 30, 128, 128)
    screen.drawText("PlasmaPuffs", 0, -44, 16, 999)
    screen.drawText("Productions", 0, -64, 16, 999)
    screen.setAlpha(1)
  end
end

