Hitbox = class
  RECTANGLE = 1
  CIRCLE = 2
  
  constructor = function()
    this.rx = 0
    this.ry = 0
    this.width = 0
    this.height = 0
    
    this.cx = 0
    this.cy = 0
    this.radius = 0
  end
  
  vertices = function()
    local w = this.width / 2
    local h = this.height / 2
    
    return [
      object
        x = this.rx - w
        y = this.ry - h
      end,
      object
        x = this.rx - w
        y = this.ry + h
      end,
      object
        x = this.rx + w
        y = this.ry - h
      end,
      object
        x = this.rx + w
        y = this.ry + h
      end
    ]
  end
  
  intersection = function(hitbox, shape)
    if shape == Hitbox.RECTANGLE then
      local w1 = this.width / 2
      local h1 = this.height / 2
      local w2 = hitbox.width / 2
      local h2 = hitbox.height / 2
      return
        this.rx - w1 <= hitbox.rx + w2 and
        this.rx + w1 >= hitbox.rx - w2 and
        this.ry - h1 <= hitbox.ry + h2 and
        this.ry + h1 >= hitbox.ry - h2
    elsif shape == Hitbox.CIRCLE then
      local dx = this.cx - hitbox.cx
      local dy = this.cy - hitbox.cy
      return sqrt(pow(dx, 2) + pow(dy, 2)) <= this.radius + hitbox.radius
    end
    
    return false
  end
  
  draw = function()
    screen.setLineWidth(0.5)
    screen.drawRect(this.rx, this.ry, this.width, this.height, "#00FFFF")
    screen.drawRound(this.cx, this.cy, this.radius * 2, this.radius * 2, 900)
    screen.resetLineWidth()
  end
end
