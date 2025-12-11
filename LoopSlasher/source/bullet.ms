Bullet = class
  IDENTIFIER = "Bullet"

  constructor = function(game, x, y, direction, speed)
    this.game = game

    this.x = x
    this.y = y
    this.direction = direction
    this.vx = cosd(direction) * speed
    this.vy = sind(direction) * speed
    this.ax = 0
    this.ay = 0
    
    this.hitbox = new Hitbox()
    this.hitbox.cx = this.x
    this.hitbox.cy = this.y
    this.hitbox.radius = 4
    
    this.glow = new glow(64)
    this.scale = 1

    this.drawRequest = object
      data = this
      layer = global.Layer.FLOATING_BULLET
      callback = function(data)
        screen.setDrawRotation(data.direction)
        screen.setDrawScale(data.scale * 2, data.scale)
        data.glow.draw(data.x, data.y, global.TILE_SIZE, "rgb(236, 198, 255)")
        screen.setDrawScale(data.scale, data.scale)
        screen.drawSprite("bullet", data.x, data.y, 12, 6)
        screen.resetDrawScale()
        screen.resetDrawRotation()
      end
    end
    
    if global.DEBUG_MODE then
      this.hitboxDrawRequest = object
        data = this
        layer = global.Layer.DEBUG_FOREGROUND
        callback = function(data)
          data.hitbox.draw()
        end
      end
    end
  end
  
  update = function(deltaTime)
    this.scale = 1 + cos(system.time() / 100) / 10

    this.vx += this.ax * deltaTime
    this.vy += this.ay * deltaTime
    this.x += this.vx * deltaTime
    this.y += this.vy * deltaTime
    
    local out = object 
      x = abs(this.x) >= screen.width / 2 + global.TILE_SIZE / 2
      y = abs(this.y) >= screen.height / 2 + global.TILE_SIZE / 2
    end
    
    if out.x or out.y then
      this.game.bullets.removeElement(this)
      return
    end
    
    this.hitbox.cx = this.x
    this.hitbox.cy = this.y
    
    if not this.game.player.rolling then
      if this.hitbox.intersection(this.game.player.hitbox, Hitbox.CIRCLE) then
        this.game.player.handleCollision(this)
      end
    end
  end
  
  draw = function()
    this.game.drawPool.push(this.drawRequest)
    
    if global.DEBUG_MODE then
      this.game.drawPool.push(this.hitboxDrawRequest)
    end
  end
end