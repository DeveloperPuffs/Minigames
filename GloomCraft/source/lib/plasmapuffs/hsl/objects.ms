
// A class that represents a surface used for casting shadows
global.Surface = class
  constructor = function(x1, y1, x2, y2)
    this.x1 = x1
    this.y1 = y1
    this.x2 = x2
    this.y2 = y2
  end
end

// An object that controls the shadows
global.Light = class
  constructor = function(x, y, angle, angleRange)
    this.x = x
    this.y = y
    this.angle = angle
    this.angleRange = angleRange
    this.angleRangeMultiplier = 1
  end
end

