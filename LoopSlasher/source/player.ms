Player = class extends Entity
  IDENTIFIER = "Player"

  constructor = function(game)
    super(game)
    
    this.hitbox.width = 8
    this.hitbox.height = 4
    this.hitbox.radius = 4

    this.acceleration = 1500
    this.moving = false
    this.flip = 1
    
    this.dead = false
    this.dyingTime = 0
    this.dyingDuration = 1
    this.dyingFrames = 4
    
    this.walkTime = 0
    this.idleTime = 0

    this.canRoll = true
    this.rolling = false
    this.rollingTime = 0
    this.rollingPower = 300
    this.rollingCooldown = 0.2
    this.rollingDuration = 0.4
    this.rollingFrames = 13
    this.savedVelocity = object
      x = 0
      y = 0
    end
    
    this.currentWobble = 0
    this.wobbleSpeed = 10
    this.wobbleDegrees = 6
    this.wobbleTime = 0
    
    this.steppingFrames = 0
    this.nextStep = random.integer(10, 15)
    
    this.trail = new Trail(this)
    this.afterimages = []
    
    local dustStartColor = object red = 0.75 green = 0.75 blue = 0.75 alpha = 1 end
    local dustEndColor = object red = 0.25 green = 0.25 blue = 0.25 alpha = 0 end
    this.dustEmitter = this.createDustEmitter(dustStartColor, dustEndColor)
    
    this.drawRequests = [
      object
        data = this
        layer = global.Layer.SURFACE_SHADOW
        callback = function(data)
          screen.setAlpha(0.5)
          screen.drawSprite("shadow", data.x, data.y - data.height / 2, data.width, data.height / 4)
          screen.resetAlpha()
        end
      end,
      object
        data = this
        layer = global.Layer.PLAYER_EFFECTS
        callback = function(data)
          screen.drawEmitter(data.dustEmitter)
          for afterimage in data.afterimages
            afterimage.draw()
          end
        end
      end,
      object
        data = this
        layer = global.Layer.PLAYER_BACK_HAND
        callback = function(data)
          local backHandPosition = data.getHandPosition(1)
          screen.setDrawRotation(backHandPosition.angle)
          screen.drawSprite("hand", backHandPosition.x, backHandPosition.y, 4, 4)
          screen.resetDrawRotation()
        end
      end
      object
        data = this
        layer = global.Layer.PLAYER_BODY
        callback = function(data)
          screen.setDrawRotation(data.currentWobble)
          screen.setDrawScale(data.flip, 1)
          screen.drawSprite(data.getSprite(), data.x, data.y, data.width, data.height)
          screen.resetDrawScale()
          screen.resetDrawRotation()
        end
      end,
      object
        data = this
        layer = global.Layer.PLAYER_FRONT_HAND
        callback = function(data)
          local frontHandPosition = data.getHandPosition(-1)
          screen.setDrawRotation(frontHandPosition.angle)
          screen.drawSprite("hand", frontHandPosition.x, frontHandPosition.y, 4, 4)
          screen.resetDrawRotation()
        end
      end
    ]
  end
  
  handleCollision = function(item, bypass = false)
    if this.dead then
      return
    end

    if not bypass then
      if this.rolling then
        return
      end
      
      if item.class.IDENTIFIER == Slime.IDENTIFIER then
        if item.dead then
          return
        end
      end
    end

    this.dead = true
    audio.playSound("death", 1)
    
    local direction = atan2d(this.y - item.y, this.x - item.x)
    this.vx = cosd(direction) * this.acceleration / 2
    this.vy = sind(direction) * this.acceleration / 2
    this.ax = 0
    this.ay = 0
    
    this.game.shake(2, 1)
  end
  
  updateHitbox = function()
    super()

    this.hitbox.ry -= 4
    this.hitbox.cy -= 2
  end
  
  getHandPosition = function(side)
    local position = object end
    
    if this.moving then
      position.angle = (sin(this.walkTime * 6) * 40 * side) - 90
      position.x = this.x + (cosd(position.angle) * 4) + (2 * this.flip * side)
      position.y = this.y + (sind(position.angle) * 4) - 2
    else
      position.angle = -90
      position.x = x + (4 * this.flip * side)
      position.y = y + cos(this.idleTime * 6) - 6
    end
    
    return position
  end
  
  getSprite = function()
    if this.dead then
      local index = floor(this.dyingTime / this.dyingDuration * this.dyingFrames)
      return sprites["player_dying"].frames[index]
    end

    if this.rolling then
      local index = floor(this.rollingTime / this.rollingDuration * this.rollingFrames)
      return sprites["player_rolling"].frames[index]
    end
    
    return if this.moving then "player_running" else "player_idle" end
  end
  
  stopRolling = function()
    this.rolling = false
    this.currentWobble = 0
    this.wobbleTime = 0
    this.rollingTime = 0
    after this.rollingCooldown seconds do
      this.canRoll = true
    end
    
    this.vx = this.savedVelocity.x
    this.vy = this.savedVelocity.y
  end
  
  update = function(deltaTime)
    if this.dead then
      this.dyingTime += deltaTime
      if this.dyingTime >= this.dyingDuration then
        this.dyingTime = this.dyingDuration
      end
    end

    this.trail.update(deltaTime)
    for afterimage in this.afterimages
      if not afterimage.update(deltaTime) then
        this.afterimages.removeElement(afterimage)
      end
    end

    if not this.dead then
      local h = keyboard.RIGHT - keyboard.LEFT
      local v = keyboard.UP - keyboard.DOWN
      local d = if h and v then 1 / sqrt(2) else 1 end
      this.ax = h * this.acceleration * d
      this.ay = v * this.acceleration * d
      this.moving = h or v
      this.flip = if h then h else this.flip end
        
      this.idleTime += if this.moving then -this.idleTime else deltaTime end
      this.walkTime += if this.moving then deltaTime else -this.walkTime end
      
      local rollInput =
        keyboard.press.SPACE or
        keyboard.press.SHIFT_LEFT or
        keyboard.press.SHIFT_RIGHT
  
      if this.rolling then
        if this.rollingTime >= this.rollingDuration then
          this.stopRolling()
        else
          local image = new Afterimage(this.getSprite(), this.x, this.y, this.width, this.height, 0.1, 0.2)
          this.afterimages.push(image)
          this.rollingTime += deltaTime
        end
      elsif rollInput and this.canRoll and this.moving then
        this.game.shake(0.5, 2)
  
        this.rolling = true
        this.canRoll = false
        audio.playSound("swoosh", 0.5)
  
        this.savedVelocity.x = this.vx
        this.savedVelocity.y = this.vy
      end
  
      if this.rolling then
        local currentDirection = atan2(this.savedVelocity.y, this.savedVelocity.x)
        this.vx = cos(currentDirection) * this.rollingPower
        this.vy = sin(currentDirection) * this.rollingPower
        this.ax = 0
        this.ay = 0
      end
    end
    
    if this.moving and not this.rolling then
      this.steppingFrames += 1

      this.wobbleTime += this.wobbleSpeed * deltaTime
      this.currentWobble = this.wobbleDegrees * sin(this.wobbleTime)

      if this.steppingFrames > this.nextStep then
        this.nextStep = random.integer(10, 15)
        this.steppingFrames = 0
        audio.playSound("step", 0.25)
      end
    else
      this.steppingFrames = 0
      this.wobbleTime = 0
      this.currentWobble = 0
    end

    super(deltaTime)
    
    if this.flip == 1 then
      this.dustEmitter.prototype.speed.setRange(-100, -150)
      this.dustEmitter.prototype.direction.setRange(0, -30)
    else
      this.dustEmitter.prototype.speed.setRange(100, 150)
      this.dustEmitter.prototype.direction.setRange(0, 30)
    end
    
    this.dustEmitter.position.x = this.x
    this.dustEmitter.position.y = this.y - this.height / 2
    this.dustEmitter.update(deltaTime, this.moving)
    
    return not this.dead
  end
  
  draw = function()
    this.trail.draw()
    super()
  end
end