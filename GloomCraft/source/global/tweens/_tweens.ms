
global.Tween = class
  constructor = function(p, a, s, f, d, e)
    this.parent = p
    this.attribute = a
    this.start = s
    this.finish = f
    this.duration = d
    this.easing = e
    
    this.current = 0
    this.progress = 0
    this.completionHandler = function() end
  end
  
  tick = function()
    this.progress += global.clock.deltaTime / this.duration
    this.progress = min(this.progress, 1)
    
    local value = this.easing(this.progress)
    this.current = this.start + ((this.finish - this.start) * value)
    this.parent[this.attribute] = this.current
    
    return not (this.progress == 1)
  end
end

