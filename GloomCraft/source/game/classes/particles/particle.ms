
global.Particle = class
  CIRCLE = "fillRound"
  RECTANGLE = "fillRect"
  
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    
    this.x = 0
    this.y = 0
    this.width = 0
    this.height = 0
    this.color = "white"
    this.shape = global.Particle.CIRCLE
    
    this.ax = 0
    this.ay = 0
    this.vx = 0
    this.vy = 0
    this.fx = 0
    this.fy = 0
    this.gx = 0
    this.gy = 0
    
    this.angle = 0
    this.torque = 0
    this.angularAcceleration = 0
    this.angularFriction = 0
    this.angularGravity = 0
    
    this.alpha = 1
    this.sx = 1
    this.sy = 1
    
    this.decay = object end
    this.decay.alpha = true
    this.decay.sx = true
    this.decay.sy = true
    
    this.life = 1
    this.lifespan = 1
  end
  
  update = function()
    local deltaTime = this.game.timer.deltaTime
    
    this.life -= deltaTime / this.lifespan
    if this.life <= 0 then
      this.parent.particles.removeElement(this)
      return
    end
    
    this.vx += this.ax * deltaTime
    this.vy += this.ay * deltaTime
    this.torque += this.angularAcceleration * deltaTime
    this.vx += this.gx * deltaTime
    this.vy += this.gy * deltaTime
    this.torque += this.angularGravity * deltaTime
    this.vx -= this.vx * this.fx * deltaTime
    this.vy -= this.vy * this.fy * deltaTime
    this.torque -= this.torque * this.angularFriction * deltaTime
    this.x += this.vx * deltaTime
    this.y += this.vy * deltaTime
    this.angle += this.torque * deltaTime
    
    if this.decay.alpha then this.alpha = this.life end
    if this.decay.sx then this.sx = this.life end
    if this.decay.sy then this.sy = this.life end
  end
  
  paint = function(surface)
    local x = this.x - this.game.camera.x
    local y = this.y - this.game.camera.y
    
    surface.setAlpha(this.alpha)
    surface.setDrawRotation(this.angle)
    surface.setDrawScale(this.sx, this.sy)
    surface[this.shape](x, y, this.width, this.height, this.color)
    surface.setDrawScale(1, 1)
    surface.setDrawRotation(0)
    surface.setAlpha(1)
  end
end


