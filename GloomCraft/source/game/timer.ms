
global.Timer = class
  constructor = function()
    this._time = system.time() / 1000
    this.fps = system.fps
    this.deltaTime = 0
    this.frames = 0
    this.speed = 1
    this.frozen = false
  end
  
  tick = function()
    this.deltaTime = ((system.time() / 1000) - this._time) * this.speed
    this.deltaTime = if this.frozen then false else min(this.deltaTime, 1) end
    this._time = system.time() / 1000
    this.fps = system.fps
    this.frames += 1
  end
end

