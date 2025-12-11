
system.javascript("""
global.parseInt = (a, b) => parseInt(a, b);
""")

global.createExplosion = function(x, y, size)
  local explosion = Emitter.explosion(size)
  explosion.renderingMode = ParticleEmitter.ALIASED
  
  local scale = screen.height / 360
  explosion.position.x = x * scale
  explosion.position.y = y * scale
  
  local hex2rgbObject = function(hex, a)
    return object
      red = parseInt(hex.slice(1, 3), 16) / 255
      green = parseInt(hex.slice(3, 5), 16) / 255
      blue = parseInt(hex.slice(5, 7), 16) / 255
      alpha = a
    end
  end
  
  explosion.prototype.color[0] = hex2rgbObject("#e5ff00", 1)
  explosion.prototype.color[0.1] = hex2rgbObject("#b8d14a", 1)
  explosion.prototype.color[0.2] = hex2rgbObject("#9ab06e", 1)
  explosion.prototype.color[0.3] = hex2rgbObject("#708763", 1)
  explosion.prototype.color[0.5] = hex2rgbObject("#4c5c52", 1)
  explosion.prototype.color[0.7] = hex2rgbObject("#393e40", 0.5)
  explosion.prototype.color[1] = hex2rgbObject("#242424", 0)
  
  global.booms.push(explosion)
  explosion.trigger()
end

global.millisecondsFormat = function(milliseconds)
  local totalSeconds = floor(milliseconds / 1000)
  local hours = floor(totalSeconds / 3600)
  local minutes = floor((totalSeconds % 3600) / 60)
  local seconds = totalSeconds % 60
  
  local paddedMinutes = (if minutes < 10 then "0" else "" end) + minutes
  local paddedSeconds = (if seconds < 10 then "0" else "" end) + seconds
  
  return (if hours > 0 then hours + ":" else "" end) + paddedMinutes + ":" + paddedSeconds
end

Clock = class
  constructor = function()
    this.startTime = system.time() / 1000
    this.currentTime = system.time() / 1000
    this.elapsedTime = 0
    this.deltaTime = 0
    this.fps = system.fps
  end
  
  tick = function()
    local currentTime = system.time() / 1000
    this.elapsedTime = currentTime - this.startTime
    this.deltaTime = currentTime - this.currentTime
    this.currentTime = currentTime
    this.fps = system.fps
  end
end

