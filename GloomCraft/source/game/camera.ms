
global.Camera = class
  constructor = function()
    this.x = 0
    this.y = 0
    
    this.tx = 0
    this.ty = 0
    this.dx = screen.width / 4
    this.dy = screen.height / 4
    
    this.sx = 0
    this.sy = 0
    this.speed = 0.05
    this.shakePower = 0
    this.shakeDecay = 0.1
    this.shakeThreshold = 0.1
    this.pan = 4
  end
  
  update = function()
    this.x += (this.tx - this.x) * this.speed
    this.y += (this.ty - this.y) * this.speed
    
    if this.shakePower then
      this.sx = ((random.next() * 2) - 1) * this.shakePower
      this.sy = ((random.next() * 2) - 1) * this.shakePower
      this.shakePower -= this.shakePower * this.shakeDecay
      if this.shakePower < this.shakeThreshold then
        this.shakePower = 0
      end
    else
      this.sx = 0
      this.sy = 0
    end
  end
  
  translate = function(surface = screen)
    local x = (this.pan * (mouse.x / (screen.width / 2))) + this.x + this.sx
    local y = (this.pan * (mouse.y / (screen.height / 2))) + this.y + this.sy
    surface.setTranslation(-x, -y)
  end
  
  transpose = function(surface = screen)
    surface.setTranslation(0, 0)
  end
  
  snap = function(x, y)
    this.tx = x
    this.ty = y
    this.x = x
    this.y = y
  end
  
  shake = function(amount)
    this.shakePower += amount
  end
  
  setFocus = function(x, y)
    this.tx = min(max(this.tx, x - (this.dx / 2)), x + (this.dx / 2))
    this.ty = min(max(this.ty, y - (this.dy / 2)), y + (this.dy / 2))
  end
end

