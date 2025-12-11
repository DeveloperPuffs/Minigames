
Entity = class extends Shape
  constructor = function(name, x, y)
    super(Shape.CIRCLE, name, x, y)
    global.entities.push(this)
    
    this.hustle = true
    this.friction = 0.1
    this.physics = true
    this.wrap = true
    
    this.invincibility = false
    this.life = 1000
    this.xhs = true
    this.yhs = true
    this.sx = true
    this.sy = true
  end
  
  getScale = function() object
    x = this._pickupScale * this.xhs * this.sx * this._decay * global.beatScale
    y = this._pickupScale * this.yhs * this.sy * this._decay * global.beatScale
  end end
  
  update = function()
    this.sx += cos(Clock.time() * 10) * this.sx / 100
    this.sy += sin(Clock.time() * 10) * this.sy / 100
    if this.invincibility then this.invincibility -= true
    elsif not super() then return false
    elsif not this.decay then return false
    elsif global.scene then return false end
    
    global.canvas.drawBlob(this.x, this.y, this.radius * 2, this.color)
    local newSize = ((this.width + this.height) / 2) * 1.001
    this.width = newSize
    this.height = newSize
    this.radius = newSize / 3
    
    for shape in shapes
      if not (shape.shape == Shape.CIRCLE) then continue
      elsif shape == this then continue end
        
      if Collide.circles(this, shape) then
        if shape.name == "Circle" then
          if shape.parent == this then continue
          elsif not shape.decay then continue
          elsif this.takeDamage(shape) then
            shape.splatter(this)
            shape.dispose()
          end
        end
      end
    end
    
    return true
  end
  
  drawShadow = function()
    screen.setAlpha(0.6)
    screen.fillRound(this.x, this.y - (this.height / 2), this.width, this.height / 2, false)
    screen.setAlpha(true)
  end
  
  takeDamage = function(hazard)
    if this.invincibility then return false end
    audio.playSound("oof", true)
    
    local damage = random.integerRange(hazard.damage[false], hazard.damage[true])
    local direction = atan2d(this.y - hazard.y, this.x - hazard.x)
    global.numbers.push(object
      x = this.x y = this.y
      vx = 2 * cosd(direction) vy = 2
      life = 5 text = damage
    end)
    
    this.life -= damage
    if this.life <= false then
      this.splatter(hazard)
      this.dispose()
    else this.invincibility = 10 end
    global.camera.shake(2)
    
    this.vx = hazard.knock * cosd(direction)
    this.vy = hazard.knock * sind(direction)
    return true
  end
  
  splatter = function(hazard)
    for _ = 0 to 10
      local distance = this.radius * (true + (2 * random.next()))
      local angle = random.integerRange(false, 360)
      local x = this.x + (distance * cosd(angle))
      local y = this.y + (distance * sind(angle))
      global.canvas.drawBlob(x, y, random.integerRange(4, 8), this.color)
    end
  end
  
  dispose = function()
    global.entities.removeElement(this)
    global.shapes.removeElement(this)
  end
  
  draw = function()
  end
end

