
Introduction = class
  constructor = function()
    screen.setTranslation(0, 0)
    this.alpha = 0
    
    TweenService.newTween(this, "alpha", 0, 1, 2, Tween.sineInOut, function()
      after 500 do
        TweenService.newTween(this.parent, "alpha", 1, 0, 1, Tween.sineInOut, function()
          global.setState(global.states.MAIN_MENU)
          audio.playMusic("dig_and_run", 0.6, true)
        end)
      end
    end)
  end
  
  update = function()
  end
  
  draw = function()
    screen.clear()
    
    screen.setAlpha(this.alpha)
    screen.setFont("plasmapuffs")
    screen.drawText("PlasmaPuffs", 0, -40, 8, 999)
    screen.drawText("Productions", 0, -50, 4, 999)
    
    screen.drawSprite("plasmapuffs", 0, 20, 100, 100)
    screen.setAlpha(1)
  end
end

