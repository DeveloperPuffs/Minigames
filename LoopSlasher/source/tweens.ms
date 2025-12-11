Tween = class
  constructor = function(p, a, s, f, d, e)
    this.parent = p
    this.attribute = a
    this.start = s
    this.finish = f
    this.duration = d
    this.easing = e
    
    this.current = 0
    this.progress = 0
    this.completionHandler = false
    this.completionHandlerData = false
  end
  
  update = function(deltaTime)
    this.progress += deltaTime / this.duration
    this.progress = min(this.progress, 1)
    
    local value = this.easing(this.progress)
    this.current = this.start + (this.finish - this.start) * value
    this.parent[this.attribute] = this.current
    
    return this.progress != 1
  end
end

TweenService = class
  constructor = function()
    this.tweens = []
  end
  
  update = function(deltaTime)
    for tween in this.tweens
      if not tween.update(deltaTime) then
        if tween.completionHandler then
          tween.completionHandler(tween.completionHandlerData)
        end

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
    local newTween = new Tween(p, a, s, f, d, e)
    return this.addTween(newTween)
  end
end

global.Easing = object end

global.Easing.linear = function(t) t end
  
global.Easing.quadIn = function(t) return t * t end
global.Easing.quadOut = function(t) return t * (2 - t) end
global.Easing.quadInOut = function(t)
  if t < 0.5 then
    return 2 * t * t
  else
    return -1 + (4 - 2 * t) * t
  end
end

global.Easing.cubeIn = function(t) return t * t * t end
global.Easing.cubeOut = function(t)
  local f = (t - 1)
  return f * f * f + 1
end
global.Easing.cubeInOut = function(t)
  if t < 0.5 then
    return 4 * t * t * t
  else
    local f = (2 * t - 2)
    return 0.5 * f * f * f + 1
  end
end

global.Easing.quartIn = function(t) return t * t * t * t end
global.Easing.quartOut = function(t)
  local f = (t - 1)
  return 1 - f * f * f * f
end
global.Easing.quartInOut = function(t)
  if t < 0.5 then
    return 8 * t * t * t * t
  else
    local f = (t - 1)
    return 1 - 8 * f * f * f * f
  end
end

global.Easing.quintIn = function(t) return t * t * t * t * t end
global.Easing.quintOut = function(t)
  local f = (t - 1)
  return f * f * f * f * f + 1
end
global.Easing.quintInOut = function(t)
  if t < 0.5 then
    return 16 * t * t * t * t * t
  else
    local f = (2 * t - 2)
    return 0.5 * f * f * f * f * f + 1
  end
end

global.Easing.sineIn = function(t) 1 - cos((t * PI) / 2) end
global.Easing.sineOut = function(t) sin((t * PI) / 2) end
global.Easing.sineInOut = function(t) -0.5 * (cos(t * PI) - 1) end