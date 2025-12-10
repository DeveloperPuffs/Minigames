
global.Clock = class
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

