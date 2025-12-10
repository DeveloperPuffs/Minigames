
global.Transition = class
  constructor = function()
    this.transitioning = false
    this.alpha = 0
  end
  
  update = function()
  end
  
  draw = function()
    screen.setAlpha(this.alpha)
    screen.setTranslation(0, 0)
    screen.fillRect(0, 0, screen.width, screen.height, 1)
    screen.setAlpha(1)
  end
  
  requestTransition = function(transitionAction, completionAction, duration)
    if this.transitioning then return end
    this.transitioning = true
    
    local transitionInTween = global.tweenService.createTween(
      this, "alpha", 0, 1, duration / 2, global.Easing.sineInOut
    )
    
    transitionInTween.completionHandler = function()
      transitionAction()
      
      local transitionOutTween = global.tweenService.createTween(
        global.transition, "alpha", 1, 0, duration / 2, global.Easing.sineInOut
      )
      
      transitionOutTween.completionHandler = function()
        global.transition.transitioning = false
        completionAction()
      end
    end
  end
end

