
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
