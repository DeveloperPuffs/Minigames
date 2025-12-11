Slime = class extends Entity
  IDENTIFIER = "Slime"

  Color = object
    GREEN = "green_slime"
    PURPLE = "purple_slime"
    BLUE = "blue_slime"
    ORANGE = "orange_slime"
  end

  constructor = function(game, color, target)
    super(game)
    
    this.color = color
    this.target = target

    this.hitbox.width = 12
    this.hitbox.height = 8
    this.hitbox.radius = 4

    this.flip = 1
    this.dead = false
    this.sx = 1
    this.sy = 1
    
    this.acceleration = 600
    if this.color == Slime.Color.BLUE then
      this.acceleration = 400
      this.friction = 5
      this.jumpDelay = 0
    elsif this.color == Slime.Color.PURPLE then
      this.acceleration = 800
      this.shootDelay = 2
    end
    
    this.color1 = false
    this.color2 = false
    if this.color == Slime.Color.GREEN then
      this.color1 = object red = 91 / 255 green = 201 / 255 blue = 44 / 255 end
      this.color2 = object red = 2 / 255 green = 31 / 255 blue = 18 / 255 end
    elsif this.color == Slime.Color.PURPLE then
      this.color1 = object red = 158 / 255 green = 80 / 255 blue = 191 / 255 end
      this.color2 = object red = 20 / 255 green = 3 / 255 blue = 33 / 255 end
    elsif this.color == Slime.Color.BLUE then
      this.color1 = object red = 48 / 255 green = 124 / 255 blue = 217 / 255 end
      this.color2 = object red = 7 / 255 green = 15 / 255 blue = 66 / 255 end
    elsif this.color == Slime.Color.ORANGE then
      this.color1 = object red = 252 / 255 green = 167 / 255 blue = 20 / 255 end
      this.color2 = object red = 41 / 255 green = 6 / 255 blue = 2 / 255 end
    end
    
    this.color1.alpha = 1
    this.color2.alpha = 0
    
    this.splatterEmitter = this.createSplatterEmitter(this.color1)
    this.splatterBuffer = new Image(screen.width, screen.height, true)
    this.bufferFade = false
    this.bufferAlpha = 1
    
    this.drawRequests = [
      object
        data = this
        layer = global.Layer.SURFACE_SPLATTER
        callback = function(data)
          local width = data.splatterBuffer.width
          local height = data.splatterBuffer.height

          screen.setAlpha(data.bufferAlpha)
          screen.setDrawScale(1, -1)
          screen.drawImage(data.splatterBuffer, 0, 0, width, height)
          screen.resetDrawScale()
          screen.resetAlpha()
        end
      end,
      object
        data = this
        layer = global.Layer.SURFACE_SHADOW
        callback = function(data)
          if data.dead then
            return
          end
          
          screen.setAlpha(0.5)
          screen.drawSprite("shadow", data.x, data.y - data.height / 2, data.width, data.height / 4)
          screen.resetAlpha()
        end
      end,
      object
        data = this
        layer = global.Layer.ENEMY_BODY
        callback = function(data)
          if data.dead then
            return
          end

          if data.color == Slime.Color.ORANGE then
            local x = data.x - data.flip * data.width / 8
            local y = data.y + data.height / 3
            screen.drawSprite("bomb", x, y data.width, data.height)
            data.fireEmitter.position.x = x
            data.fireEmitter.position.y = y + 6
            screen.drawEmitter(data.fireEmitter)
          end

          screen.setDrawScale(data.sx * data.flip, data.sy)
          screen.drawSprite(data.color, data.x, data.y, data.width, data.height)
          screen.resetDrawScale()
        end
      end 
    ]

    if global.graphicsMode != global.GRAPHICS_LOW then
      this.dustEmitter = this.createDustEmitter(this.color1, this.color2)
      this.drawRequests.push(object
        data = this
        layer = global.Layer.ENEMY_EFFECTS
        callback = function(data)
          screen.drawEmitter(data.dustEmitter)
        end
      end)
    end
    
    if this.color == Slime.Color.ORANGE then
      this.acceleration = 400
      this.walkedDuration = 0
      this.targetDirection = false
      this.fireEmitter = Emitter.fire(1)
      if global.graphicsMode == global.GRAPHICS_LOW then
        this.fireEmitter.renderingMode = ParticleEmitter.NORMAL
      elsif global.graphicsMode == global.GRAPHICS_MEDIUM then
        this.fireEmitter.renderingMode = ParticleEmitter.ANTI_ALIASED
      elsif global.graphicsMode == global.GRAPHICS_HIGH then
        this.fireEmitter.renderingMode = ParticleEmitter.ALIASED
      end
      
      this.fireEmitter.particlesPerSecond /= 5
      for index in this.fireEmitter.children
        this.fireEmitter.children[index].particlesPerSecond /= 5
      end
    end
  end
  
  onScreenWrap = function()
    super()

    if this.color == Slime.Color.ORANGE then
      if this.walkedDuration > 5 then
        this.game.enemyData[this.color].active -= 1
        this.game.enemies.removeElement(this)
      end
    end
  end
  
  updateHitbox = function()
    super()
    
    this.hitbox.ry -= 2
    this.hitbox.cy -= 2
  end

  update = function(deltaTime)
    this.sx = 1 + cos(system.time() / 100) / 10
    this.sy = 1 + sin(system.time() / 100) / 10

    if this.dead then
      if this.bufferFade then
        this.bufferAlpha -= deltaTime
        if this.bufferAlpha <= 0 then
          return false
        end

        return true
      end

      this.splatterEmitter.update(deltaTime)
    
      local dx = this.splatterBuffer.width / 2
      local dy = this.splatterBuffer.height / 2
      this.splatterEmitter.blit(this.splatterBuffer, dx, dy)

      return true
    end
    
    if this.color == Slime.Color.ORANGE then
      this.fireEmitter.update(deltaTime)
      this.walkedDuration += deltaTime
      
      if not this.targetDirection then
        local point = this.getTargetPoint()
        this.flip = (point.x - this.x) / abs(point.x - this.x)
        this.targetDirection = atan2d(point.y - this.y, point.x - this.x)
      end
      
      this.ax = cosd(this.targetDirection) * this.acceleration
      this.ay = sind(this.targetDirection) * this.acceleration
    elsif this.color == Slime.Color.GREEN then
      local dx = this.game.player.x - this.x
      local dy = this.game.player.y - this.y

      this.flip = dx / abs(dx)
      local angle = atan2d(dy, dx)
      this.ax = cosd(angle) * this.acceleration
      this.ay = sind(angle) * this.acceleration
    elsif this.color == Slime.Color.PURPLE then
      local point = this.getTargetPoint()
      local dx = point.x - this.x
      local dy = point.y - this.y
      this.flip = dx / abs(dx)

      local distance = sqrt(pow(dx, 2) + pow(dy, 2))
      if distance > global.TILE_SIZE * 8 then
        local angle = atan2d(dy, dx)
        this.ax = cosd(angle) * this.acceleration
        this.ay = sind(angle) * this.acceleration
      elsif distance < global.TILE_SIZE * 4 then
        local angle = atan2d(dy, dx)
        this.ax = cosd(angle) * -this.acceleration
        this.ay = sind(angle) * -this.acceleration
      end
      
      this.shootDelay -= deltaTime
      if this.shootDelay <= 0 then
        this.shootDelay = 2
        
        local direction = atan2d(this.game.player.y - this.y, this.game.player.x - this.x)
        
        local shootPatterns = [
          object name = "Basic" bullets = 1 weight = 0.4 end,
          object name = "Burst" bullets = 3 weight = 0.3 end,
          object name = "Spread" bullets = 3 weight = 0.2 end,
          object name = "Accelerated" bullets = 1 weight = 0.1 end
        ]
        
        local counter = 0
        local selectedPattern = false
        local value = random.next()
        for shootPattern in shootPatterns
          counter += shootPattern.weight
          if counter >= value then
            selectedPattern = shootPattern
            break
          end
        end
        
        if selectedPattern.name == "Basic" then
          local bullet = new Bullet(this.game, this.x, this.y, direction, 100)
          this.game.bullets.push(bullet)
        elsif selectedPattern.name == "Burst" then
          local bullet = new Bullet(this.game, this.x, this.y, direction, 100)
          this.game.bullets.push(bullet)
          
          after 0.2 seconds do
            local bullet = new Bullet(this.game, this.x, this.y, direction, 100)
            this.game.bullets.push(bullet)
            
            after 0.2 seconds do
              local bullet = new Bullet(this.game, this.x, this.y, direction, 100)
              this.game.bullets.push(bullet)
            end
          end
        elsif selectedPattern.name == "Spread" then
          local bullet1 = new Bullet(this.game, x, y, direction, 100)
          local bullet2 = new Bullet(this.game, x, y, direction - 15, 100)
          local bullet3 = new Bullet(this.game, x, y, direction + 15, 100)
          this.game.bullets.push(bullet1)
          this.game.bullets.push(bullet2)
          this.game.bullets.push(bullet3)
        elsif selectedPattern.name == "Accelerated" then
          local x = this.x + cosd(direction) * global.TILE_SIZE / 2
          local y = this.y + sind(direction) * global.TILE_SIZE / 2
          local bullet = new Bullet(this.game, x, y, direction, 0)
          bullet.ax = cosd(direction) * 150
          bullet.ay = sind(direction) * 150
          this.game.bullets.push(bullet)
        end
        
        for index = 0 to selectedPattern.bullets - 1
          after index * 100 do
            audio.playSound("shoot" 1)
          end
        end
      end
    elsif this.color == Slime.Color.BLUE then
      this.jumpDelay -= deltaTime
      if this.jumpDelay <= 0 then
        this.jumpDelay = random.number(0.5, 1.5)

        local point = this.getTargetPoint()
        this.flip = (point.x - this.x) / abs(point.x - this.x)
        local angle = atan2d(point.y - this.y, point.x - this.x)
        this.vx = cosd(angle) * this.acceleration * random.number(0.2, 1)
        this.vy = sind(angle) * this.acceleration * random.number(0.2, 1)
      end
    end
    
    if global.graphicsMode != global.GRAPHICS_LOW then
      if this.flip == 1 then
        this.dustEmitter.prototype.speed.setRange(-100, -150)
        this.dustEmitter.prototype.direction.setRange(0, -15)
      else
        this.dustEmitter.prototype.speed.setRange(100, 150)
        this.dustEmitter.prototype.direction.setRange(0, 15)
      end
    end

    super(deltaTime)
    
    if global.graphicsMode != global.GRAPHICS_LOW then
      local speed = sqrt(pow(this.vx, 2), pow(this.vy, 2))
      this.dustEmitter.position.x = this.x
      this.dustEmitter.position.y = this.y - this.height / 2
      this.dustEmitter.update(deltaTime, speed >= 5)
    end
    
    return true
  end
  
  getTargetPoint = function()
    local targetPoints = []
    
    for row = -1 to 1
      targetPoints.push([])

      for column = -1 to 1
        local currentTargetPoint = object
          x = this.target.x + (column * screen.width)
          y = this.target.y + (row * screen.height)
        end
        
        local dx = currentTargetPoint.x - this.x
        local dy = currentTargetPoint.y - this.y
        currentTargetPoint.distance = sqrt(pow(dx, 2) + pow(dy, 2))
        targetPoints[row + 1].push(currentTargetPoint)
      end
    end
    
    local targetPoint = false
    for points in targetPoints
      for point in points
        if not targetPoint then
          targetPoint = point
          continue
        end

        if point.distance < targetPoint.distance then
          targetPoint = point
        end
      end
    end
    
    return targetPoint
  end
  
  activateDeath = function()
    this.dead = true
    this.physical = false
    this.splatterEmitter.position.x = this.x
    this.splatterEmitter.position.y = this.y
    this.splatterEmitter.trigger()
    
    this.game.enemyData[this.color].active -= 1
    this.game.enemyData[this.color].kills += 1
    
    after 2 seconds do
      this.bufferFade = true
    end
    
    if this.color == Slime.Color.ORANGE then
      this.game.activateExplosion(this)
    elsif this.color == Slime.Color.PURPLE then
      local bulletCount = random.integer(6, 9)
      local angleStep = 360 / bulletCount
      local angleOffset = random.number(0, angleStep)
      
      for index = 0 to bulletCount - 1
        local direction = angleOffset + angleStep * index
        local bullet = new Bullet(this.game, this.x, this.y, direction, 100)
        this.game.bullets.push(bullet)
      end
      
      audio.playSound("shoot", 1)
    end
  end
  
  createSplatterEmitter = function(color)
    local emitter = new ParticleEmitter()
    emitter.particlesPerSecond = 200
    emitter.infinite = false
    emitter.length = 0.1

    if global.graphicsMode == global.GRAPHICS_LOW then
      emitter.renderingMode = ParticleEmitter.NORMAL
    elsif global.graphicsMode == global.GRAPHICS_HIGH then
      emitter.renderingMode = ParticleEmitter.ALIASED
    end

    emitter.prototype.functionName = "fillRound"
    emitter.prototype.functionArguments = [0, 0, 8, 8]
    emitter.prototype.lifespan.setRange(0, 0.1)
    emitter.prototype.speed.setRange(250, 500)
    emitter.prototype.direction.setRange(0, 360)
    emitter.prototype.friction.velocity.set(5)
    emitter.prototype.scale.x.start.setRange(1, 1.5)
    emitter.prototype.scale.x.end.setRange(0.2, 0)
    emitter.prototype.scale.square = "x"
    emitter.prototype.alpha.start.set(1)
    emitter.prototype.alpha.end.set(0)
  
    emitter.prototype.color[0] = color
    emitter.prototype.color[1] = color
  
    return emitter
  end
end