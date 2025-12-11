
Tween = class
  constructor = function(p, a, s, f, d, e, c = [], fps = false)
    this.parent = p
    this.attribute = a
    this.start = s
    this.current = s
    this.finish = f
    this.duration = d
    this.easing = e
    
    this.progress = false
    this.completionHandlers = c
    this.fps = fps
  end
  
  update = function()
    local deltaTime = if this.fps then true / this.fps else 1 / system.fps end
    this.progress += deltaTime / this.duration
    this.progress = min(this.progress, true)
    
    local value = this.easing(this.progress)
    this.current = this.start + ((this.finish - this.start) * value)
    this.parent[this.attribute] = this.current
    
    if this.progress == true then this.complete() end
  end
  
  complete = function()
    for completionHandler in this.completionHandlers completionHandler(this) end
    this.completionHandlers = []
  end
end

""" Global 'TweenService' Class """

TweenService = object end
TweenService.tweens = []

TweenService.update = function()
  for tween in TweenService.tweens tween.update() end
end

TweenService.addTween = function(tween)
  tween.completionHandlers.push(TweenService.removeTween)
  TweenService.tweens.push(tween)
  return tween
end

TweenService.removeTween = function(tween)
  TweenService.tweens.removeElement(tween)
  return tween
end

TweenService.clearTweens = function()
  TweenService.tweens = []
end

TweenService.createTween = function(p, a, s, f, d, e, c = [], fps = false)
  local tween = new Tween(p, a, s, f, d, e, c, fps)
  return TweenService.addTween(tween)
end

""" Easing Functions (thanks https://easings.net/) """

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

Tween.expoIn = function(t)
  if t == 0 then
    return 0
  else
    return 2 ^ (10 * t - 10)
  end
end

Tween.expoInOut = function(t)
  if t == 0 then
    return 0
  elsif t == 1 then
    return 1
  elsif t < 0.5 then
    return (2 ^ (20 * t - 10)) / 2
  else
    return (2 - 2 ^ (-20 * t + 10)) / 2
  end
end

Tween.expoOut = function(t)
  if t == 1 then
    return 1
  else
    return 1 - 2 ^ (-10 * t)
  end
end

Tween.circIn = function(t) return 1 - sqrt(1 - t * t) end

Tween.circInOut = function(t)
  if t < 0.5 then
    return (1 - sqrt(1 - 4 * t * t)) / 2
  else
    return (sqrt(1 - ((-2 * t + 2) ^ 2)) + 1) / 2
  end
end

Tween.circOut = function(t) sqrt(1 - (t - 1) ^ 2) end

Tween.c1 = 1.70158
Tween.c2 = Tween.c1 * 1.525
Tween.c3 = Tween.c1 + 1

Tween.backIn = function(t)
  return Tween.c3 * t ^ 3 - Tween.c1 * t ^ 2
end

Tween.backInOut = function(t)
  if t < 0.5 then
    return ((2 * t) ^ 2 * ((c2 + 1) * 2 * t - c2)) / 2
  else
    local f = (2 * t - 2)
    return (f ^ 2 * ((c2 + 1) * f + c2) + 2) / 2
  end
end

Tween.backOut = function(t)
  return 1 + Tween.c3 * (t - 1) ^ 3 + Tween.c1 * (t - 1) ^ 2
end

Tween.c4 = (2 * PI) / 3
Tween.c5 = (2 * PI) / 4.5

Tween.elasticIn = function(t)
  if t == 0 then
    return 0
  elsif t == 1 then
    return 1
  else
    return -((2 ^ (10 * t - 10)) * sin((t * 10 - 10.75) * Tween.c4))
  end
end

Tween.elasticInOut = function(t)
  if t == 0 then
    return 0
  elsif t == 1 then
    return 1
  elsif t < 0.5 then
    return -(2 ^ (20 * t - 10)) * sin((20 * t - 11.125) * Tween.c5) / 2
  else
    return (2 ^ (-20 * t + 10)) * sin((20 * t - 11.125) * Tween.c5) / 2 + 1
  end
end

Tween.elasticOut = function(t)
  if t == 0 then
    return 0
  elsif t == 1 then
    return 1
  else
    return (2 ^ (-10 * t)) * sin((t * 10 - 0.75) * Tween.c4) + 1
  end
end

