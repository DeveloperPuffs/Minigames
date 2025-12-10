
Tween = class
  constructor = function(
    parent, attribute,
    start, finish,
    duration, easing,
    completionHandler = function() end)
    this.parent = parent
    this.attribute = attribute
    this.start = start
    this.finish = finish
    this.duration = duration
    this.easing = easing
    
    this.progress = 0
    this.completionHandler = completionHandler
  end
  
  tick = function()
    this.progress += system.deltaTime / this.duration
    this.progress = min(this.progress, 1)
    
    local value = this.start + ((this.finish - this.start) * this.easing(this.progress))
    this.parent[this.attribute] = value
  end
end

TweenService = object
  tweens = []
end

TweenService.tick = function()
  for tween in TweenService.tweens
    tween.tick()
    
    if tween.progress == 1 then
      tween.completionHandler()
      TweenService.tweens.removeElement(tween)
    end
  end
end

TweenService.addTween = function(tween)
  TweenService.tweens.push(tween)
end

TweenService.newTween = function(
  parent, attribute,
  start, finish,
  duration, easing,
  completionHandler = function() end)
  local tween = new Tween(parent, attribute, start, finish, duration, easing, completionHandler)
  TweenService.addTween(tween)
  return tween
end

TweenService.removeTween = function(tween)
  TweenService.tweens.removeElement(tween)
end

Tween.linear = function(t) t end
  
Tween.quadIn = function(t) return t * t end
Tween.quadOut = function(t) return t * (2 - t) end
Tween.quadInOut = function(t)
  if t < 0.5 then
    return 2 * t * t
  else
    return -1 + (4 - 2 * t) * t
  end
end

Tween.cubeIn = function(t) return t * t * t end
Tween.cubeOut = function(t)
  local f = (t - 1)
  return f * f * f + 1
end
Tween.cubeInOut = function(t)
  if t < 0.5 then
    return 4 * t * t * t
  else
    local f = (2 * t - 2)
    return 0.5 * f * f * f + 1
  end
end

Tween.quartIn = function(t) return t * t * t * t end
Tween.quartOut = function(t)
  local f = (t - 1)
  return 1 - f * f * f * f
end
Tween.quartInOut = function(t)
  if t < 0.5 then
    return 8 * t * t * t * t
  else
    local f = (t - 1)
    return 1 - 8 * f * f * f * f
  end
end

Tween.quintIn = function(t) return t * t * t * t * t end
Tween.quintOut = function(t)
  local f = (t - 1)
  return f * f * f * f * f + 1
end
Tween.quintInOut = function(t)
  if t < 0.5 then
    return 16 * t * t * t * t * t
  else
    local f = (2 * t - 2)
    return 0.5 * f * f * f * f * f + 1
  end
end

Tween.sineIn = function(t) 1 - cos((t * PI) / 2) end
Tween.sineOut = function(t) sin((t * PI) / 2) end
Tween.sineInOut = function(t) -0.5 * (cos(t * PI) - 1) end

