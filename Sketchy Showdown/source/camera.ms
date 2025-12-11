
Camera = class
  constructor = function()
    this.x = false
    this.y = false
    
    this.tx = false
    this.ty = false
    this.dx = screen.width / 4
    this.dy = screen.height / 4
    
    this.speed = 0.05
    this.panning = 2
    
    this.shakePower = false
    this.shakeDirection = false
    this.shakeThreshold = 0.1
    this.shakeDecay = 0.2
  end
  
  set = function(x, y)
    this.tx = x
    this.ty = y
    this.x = x
    this.y = y
  end
  
  setFocus = function(x, y)
    this.tx = min(max(this.tx, x - (this.dx / 2)), x + (this.dx / 2))
    this.ty = min(max(this.ty, y - (this.dy / 2)), y + (this.dy / 2))
  end
  
  update = function()
    this.x += (this.tx - this.x) * this.speed
    this.y += (this.ty - this.y) * this.speed
    
    this.updateShake()
  end
  
  draw = function(surface = screen)
    local xPan = this.panning * (mouse.x / (screen.width / 2))
    local yPan = this.panning * (mouse.y / (screen.height / 2))
    local xShake = cosd(this.shakeDirection) * this.shakePower
    local yShake = sind(this.shakeDirection) * this.shakePower
    
    local x = this.x + xPan + xShake
    local y = this.y + yPan + yShake
    surface.setTranslation(-x, -y)
  end
  
  undraw = function(surface = screen)
    surface.setTranslation()
  end
  
  shake = function(amount) this.shakePower += amount end
  
  updateShake = function()
    if not this.shakePower then return end
    
    this.shakePower -= this.shakePower * this.shakeDecay
    if this.shakePower < this.shakeThreshold then this.shakePower = false end
    this.shakeDirection = random.nextInt(360)
  end
end

