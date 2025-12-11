Entity = class
  IDENTIFIER = "Entity"

  constructor = function(game)
    this.game = game

    this.x = 0
    this.y = 0
    this.vx = 0
    this.vy = 0
    this.ax = 0
    this.ay = 0
    this.friction = 10

    this.width = global.TILE_SIZE
    this.height = global.TILE_SIZE

    this.physical = true
    this.hitbox = new Hitbox()
    if global.DEBUG_MODE then
      this.hitboxDrawRequest = object
        data = this
        layer = global.Layer.DEBUG_FOREGROUND
        callback = function(data)
          data.hitbox.draw()
        end
      end
    end

    this.drawRequests = []
  end
  
  createDustEmitter = function(color1, color2)
    local emitter = new ParticleEmitter()
    emitter.particlesPerSecond = 5
    
    if global.graphicsMode == global.GRAPHICS_HIGH then
      emitter.renderingMode = ParticleEmitter.ALIASED
    elsif global.graphicsMode == global.GRAPHICS_MEDIUM then
      emitter.renderingMode = ParticleEmitter.ANTI_ALIASED
    elsif global.graphicsMode == global.GRAPHICS_LOW then
      emitter.renderingMode = ParticleEmitter.NORMAL
    end
    
    emitter.prototype.functionName = "fillRound"
    emitter.prototype.functionArguments = [0, 0, 5, 5]
    emitter.prototype.lifespan.setRange(0.5, 1)
    emitter.prototype.speed.setRange(100, 150)
    emitter.prototype.direction.setRange(0, 30)
    emitter.prototype.friction.velocity.set(5)
    emitter.prototype.scale.x.start.setRange(0.5, 1.0)
    emitter.prototype.scale.x.end.setRange(0.5, 0)
    emitter.prototype.scale.square = "x"
    emitter.prototype.alpha.start.setRange(0.5, 1)
    emitter.prototype.alpha.end.set(0, 0.5)
    
    emitter.prototype.color[0] = color1
    emitter.prototype.color[1] = color2
    
    return emitter
  end
  
  screenWrap = function()
    local x = this.x
    local y = this.y

    if this.vx < 0 and this.x + this.width / 2 < screen.width / -2 then
      this.x = (screen.width / 2) + this.width / 2
    elsif this.vx > 0 and this.x - this.width / 2 > screen.width / 2 then
      this.x = (screen.width / -2) - this.width / 2
    end
    
    if this.vy < 0 and this.y + this.height / 2 < screen.height / -2 then
      this.y = (screen.height / 2) + this.height / 2
    elsif this.vy > 0 and this.y - this.height / 2 > screen.height / 2 then
      this.y = (screen.height / -2) - this.height / 2
    end
    
    if this.x != x or this.y != y then
      this.onScreenWrap()
    end
  end
  
  onScreenWrap = function()
  end
  
  updateHitbox = function()
    this.hitbox.cx = this.x
    this.hitbox.cy = this.y
    this.hitbox.rx = this.x
    this.hitbox.ry = this.y
  end
  
  update = function(deltaTime)
    if not this.physical then
      return
    end

    this.vx += this.ax * deltaTime
    this.vy += this.ay * deltaTime
    this.vx -= this.vx * min(this.friction * deltaTime, 1)
    this.vy -= this.vy * min(this.friction * deltaTime, 1)
    this.x += this.vx * deltaTime
    this.y += this.vy * deltaTime
    
    this.screenWrap()
    this.updateHitbox()
  end
  
  draw = function()
    for request in this.drawRequests
      this.game.drawPool.push(request)
    end
    
    if global.DEBUG_MODE and this.physical then
      this.game.drawPool.push(this.hitboxDrawRequest)
    end
  end
end