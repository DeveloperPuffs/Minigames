
global.TweenService = class
  constructor = function()
    this.tweens = []
  end
  
  tick = function()
    for tween in this.tweens
      if not tween.tick() then
        tween.completionHandler()
        this.removeTween(tween)
      end
    end
  end
  
  addTween = function(tween)
    this.tweens.push(tween)
    return tween
  end
  
  removeTween = function(tween)
    if this.tweens.contains(tween) then
      this.tweens.removeElement(tween)
    end
    
    return tween
  end
  
  clearTweens = function()
    this.tweens = []
  end
  
  createTween = function(p, a, s, f, d, e)
    local newTween = new global.Tween(p, a, s, f, d, e)
    return this.addTween(newTween)
  end
end

