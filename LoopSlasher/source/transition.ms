Transition = class
  constructor = function()
    this.transitioning = false
    this.transitionAction = false
    this.completionAction = false
    this.alpha = 0
  end
  
  draw = function()
    screen.setAlpha(this.alpha)
    screen.fillRect(0, 0, screen.width, screen.height, "black")
    screen.resetAlpha()
  end
  
  requestTransition = function(transitionAction, completionAction, duration)
    if this.transitioning then
      return false
    end

    this.transitioning = true
    this.transitionAction = transitionAction
    this.completionAction = completionAction

    local transitionInTween = global.tweenService.createTween(this, "alpha", 0, 1, duration / 2, Easing.sineInOut)
    transitionInTween.completionHandlerData = this
    transitionInTween.completionHandler = function(data)
      if data.transitionAction then
        data.transitionAction()
      end
      
      local transitionOutTween = global.tweenService.createTween(data, "alpha", 1, 0, duration / 2, Easing.sineInOut)
      transitionOutTween.completionHandlerData = data
      transitionOutTween.completionHandler = function(data)
        data.transitioning = false
        if data.completionAction then
          data.completionAction()
        end
      end
    end
    
    return true
  end
end