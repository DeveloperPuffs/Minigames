
global.Player = class
  constructor = function(game)
    this.game = game
    this.identifier = "player"
    this.frozen = false
    
    this.light = new global.Light(0, 0, 0, 0)
    this.lightTween = false
    
    this.x = 0
    this.y = 0
    this.vx = 0
    this.vy = 0
    
    this.flip = 1
    this.width = 16
    this.height = 16
    this.column = 0
    this.row = 0
    this.scale = [1, 1]
    
    this.hitbox = new global.Hitbox()
    this.hitbox.rectangle.width = 8
    this.hitbox.rectangle.height = 4
    this.hitbox.circle.radius = 8
    
    this.handWidth = 4
    this.handHeight = 4
    this.handAngle = 0
    this.handDistance = 8
    this.handOffsets = [0, 0]
    this.equipment = false
    
    this.rollingFrames = 0
    this.rollingInterval = 2
    this.rollingDirection = [0, 0]
    this.rollingPower = 4
    this.rollingCooldown = 0.5
    this.canRoll = true
    
    this.currentWobble = 0
    this.wobbleSpeed = 10
    this.wobbleDegrees = 6
    this.wobbleTime = 0
    this.sine = function(t) sin(t) end
    this.cosine = function(t) sin(t) end
    this.wobbleWave = random.choice([this.sine, this.cosine])
    
    this.steppingFrames = 0
    this.nextStep = random.nextInt(5) + 15
    
    local sampleTrailParticle = function(self, game, emitter)
      local particle = new global.Particle(game, emitter)
      
      local size = random.integerRange(6, 8)
      particle.width = size
      particle.height = size
      
      local lightness = random.integerRange(50, 100)
      local alpha = random.floatRange(0.4, 0.8)
      particle.color = (
        "rgba(" +
        lightness + ", " +
        lightness + ", " +
        lightness + ", " +
        alpha + ")"
      )
      
      particle.x = self.x + random.integerRange(-8, 8)
      particle.y = self.y - 8
      
      particle.lifespan = random.floatRange(0.2, 0.6)
      particle.decay.alpha = true
      particle.decay.sx = true
      particle.decay.sy = true
      
      particle.vx = random.integerRange(10, 20) * -self.flip
      particle.vy = random.integerRange(20, 40)
      
      return particle
    end
    
    this.trail = new global.Emitter(this.game, sampleTrailParticle, this)
    this.trail.interval = 4
    this.trail.chance = 0.4
    
    this.friction = 5
    this.precision = 5
    this.acceleration = 8
    
    this.afterimages = []
    
    this.hurtFrames = 0
    this.hurtDuration = 6
    this.invincible = 0
    this.invincibleDuration = 20
    
    this.lifeBar = new global.Bar(this.game, "Life", "life_bar", 5, -5)
    this.lifeBar.total = 100
    this.lifeBar.current = 100
    this.lifeBar.regeneration = 0.5
    
    this.manaBar = new global.Bar(this.game, "Mana", "mana_bar", 5, -15)
    this.manaBar.total = 100
    this.manaBar.current = 100
    this.manaBar.regeneration = 2
    
    this.deathFrames = 0
    this.deathInterval = 2
    this.dead = false
    
    this.balance = 0
    this.displayBalance = 0
    this.inventory = new global.Inventory(this.game, this)
    
    this.data = []
    this.updateData()
  end
  
  update = function()
    for afterimage in this.afterimages
      if not afterimage.update() then
        this.afterimages.removeElement(afterimage)
      end
    end
    
    this.scale[0] += ((1 - this.scale[0]) * 0.1)
    this.scale[1] += ((1 - this.scale[1]) * 0.1)
    
    this.light.x = this.x
    this.light.y = this.y - 6
    
    this.lifeBar.update()
    this.manaBar.update()
    this.inventory.update()
    this.trail.update()
    if not (this.equipment.type == "number") then this.equipment.update() end
    
    if not (this.displayBalance == this.balance) then
      local difference = this.balance - this.displayBalance
      this.displayBalance += difference / abs(difference)
    end
    
    if keyboard.press.Z then
      if this.inventory.showing then
        if this.inventory.state == global.Inventory.IDLE then
          this.inventory.setVisibility(false)
        end
      else
        this.inventory.state = global.Inventory.IDLE
        this.inventory.setVisibility(true)
      end
    end
    
    this.game.camera.setFocus(this.x, this.y)
    if this.dead or this.frozen or this.inventory.showing then
      this.trail.active = false
      return
    end
    
    local deltaTime = min(this.game.timer.deltaTime, 1 / this.friction)
    local leftInput = keyboard.LEFT or gamepad.LEFT
    local rightInput = keyboard.RIGHT or gamepad.RIGHT
    local upInput = keyboard.UP or gamepad.UP
    local downInput = keyboard.DOWN or gamepad.DOWN
    
    local horizontalInput = rightInput - leftInput
    local verticalInput = upInput - downInput
    
    this.flip = if horizontalInput then horizontalInput else this.flip end
    
    if horizontalInput and verticalInput then
      horizontalInput /= sqrt(2)
      verticalInput /= sqrt(2)
    end
    
    local moving = round(sqrt(pow(this.vx, 2) + pow(this.vy, 2)))
    this.trail.active = moving
    
    local roll = (
      keyboard.press.SPACE or
      keyboard.press.SHIFT_LEFT or
      keyboard.press.SHIFT_RIGHT
    )
    
    if this.rollingFrames then
      if this.rollingFrames > 12 * this.rollingInterval then this.stopRolling()
      else
        local index = floor(this.rollingFrames / this.rollingInterval)
        local frame = global.sprites["player/rolling"].frames[index]
        local afterimage = new global.Afterimage(
          frame, this.x, this.y,
          this.width, this.height,
          0.1, 0.2
        )
        
        this.afterimages.push(afterimage)
        this.rollingFrames += 1 
      end
    elsif roll and this.canRoll and moving then
      this.game.camera.shake(4)
      this.rollingFrames = 1
      this.canRoll = false
      audio.playSound("swoosh", 0.1)
      
      local currentDirection = atan2(this.vy, this.vx)
      this.rollingDirection = [
        cos(currentDirection) * this.rollingPower,
        sin(currentDirection) * this.rollingPower
      ]
    end
    
    if this.deathFrames then
      if this.deathFrames > 3 * this.deathInterval then
        this.deathFrames = 0
        this.die()
      else this.deathFrames += 1 end
    else
      this.vx += horizontalInput * this.acceleration * deltaTime
      this.vy += verticalInput * this.acceleration * deltaTime
    end
    
    if this.rollingFrames then
      this.vx = this.rollingDirection[0]
      this.vy = this.rollingDirection[1]
    end
    
    local collided = global.applyPhysics(this)
    if collided and this.rollingFrames then this.stopRolling() end
    this.column = floor(this.x / 16)
    this.row = floor(this.y / 16)
    
    if moving and not this.rollingFrames then
      this.steppingFrames += 1
      
      if not this.wobbleTime then
        if this.wobbleWave == this.sine then
          this.wobbleWave = this.cosine
        elsif this.wobbleWave == this.cosine then
          this.wobbleWave = this.sine
        end
      end
      
      this.wobbleTime += deltaTime * this.wobbleSpeed
      local wobbleValue = this.wobbleWave(this.wobbleTime)
      this.currentWobble = this.wobbleDegrees * wobbleValue
      
      if this.steppingFrames > this.nextStep then
        this.nextStep = random.nextInt(5) + 15
        this.steppingFrames = 0
        audio.playSound("step", 0.2)
      end
    else
      this.steppingFrames = 0
      this.wobbleTime = 0
      this.currentWobble = 0
    end
    
    this.handAngle = atan2d(
      mouse.y - (this.y - this.game.camera.y),
      mouse.x - (this.x - this.game.camera.x)
    )
    
    this.handOffsets = [
      cosd(this.handAngle) * this.handDistance,
      sind(this.handAngle) * this.handDistance
    ]
    
    this.light.angle = atan2d(
      mouse.y - (this.light.y - this.game.camera.y),
      mouse.x - (this.light.x - this.game.camera.x)
    )
    
    if not (this.equipment.type == "number") and not this.game.timer.frozen then
      if mouse.left then this.equipment.useLeft() end
      if mouse.right then this.equipment.useRight() end
    end
    
    if this.hurtFrames > 0 then 
      this.hurtFrames -= 1
      
      if not this.hurtFrames and not floor(this.lifeBar.current) then
        this.stopRolling()
        audio.playSound("death", 0.2)
        this.game.camera.shake(10)
        this.deathFrames += 1
      end
    end
  
    if this.invincible > 0 then this.invincible -= 1 end
  end
  
  updateHitbox = function()
    this.hitbox.circle.x = this.x
    this.hitbox.circle.y = this.y
    this.hitbox.rectangle.x = this.x
    this.hitbox.rectangle.y = this.y - 4
  end
  
  drawHand = function()
    screen.setDrawRotation(this.handAngle)
    if this.hurtFrames then
      screen.drawSpriteWithColor(
        "player/hand", 
        this.x + this.handOffsets[0],
        this.y + this.handOffsets[1],
        this.handWidth, this.handHeight,
        "white"
      )
    else
      screen.drawSprite(
        "player/hand", 
        this.x + this.handOffsets[0],
        this.y + this.handOffsets[1],
        this.handWidth, this.handHeight
      )
    end
    
    screen.setDrawRotation(0)
    if not (this.equipment.type == "number") then this.equipment.draw() end
  end
  
  drawBody = function()
    this.trail.draw(this.game.camera.x, this.game.camera.y)
    for afterimage in this.afterimages afterimage.draw() end
    
    if this.handAngle >= 0 then this.drawHand() end
    
    screen.setDrawScale(this.scale[0] * this.flip, this.scale[1])
    screen.setDrawRotation(this.currentWobble)
    
    if this.dead then
      screen.drawSprite(
        sprites["player/dying"].frames[3],
        this.x, this.y,
        this.width, this.height
      )
    elsif this.deathFrames then
      local index = floor(this.deathFrames / this.deathInterval)
      local frame = sprites["player/dying"].frames[index]
      screen.drawSprite(frame, this.x, this.y, this.width, this.height)
    elsif this.rollingFrames then
      local index = floor(this.rollingFrames / this.rollingInterval)
      local frame = sprites["player/rolling"].frames[index]
      if this.hurtFrames then
        screen.drawSpriteWithColor(
          frame, this.x, this.y,
          this.width, this.height, "white"
        )
      else screen.drawSprite(frame, this.x, this.y, this.width, this.height) end
    else
      local sprite = "player/"
      if round(sqrt(pow(this.vx, 2) + pow(this.vy, 2))) then
        sprite += "running"
      else sprite += "idle" end
      
      if this.hurtFrames then
        screen.drawSpriteWithColor(
          sprite, this.x, this.y,
          this.width, this.height, "white"
        )
      else
        screen.drawSprite(
          sprite, this.x, this.y,
          this.width, this.height
        )
      end
    end
    
    screen.setDrawScale(1, 1)
    screen.setDrawRotation(0)
    
    if this.handAngle < 0 then this.drawHand() end
  end
  
  drawShadows = function()
    local surfaces = this.game.dungeon.surfaces
    local position = [this.game.camera.x, this.game.camera.y]
    local culledSurfaces = global.getCulledSurfaces(surfaces, position)
    screen.drawShadows(this.light, culledSurfaces, 1)
  end
  
  drawStats = function()
    this.lifeBar.draw()
    this.manaBar.draw()
    
    local x = (screen.width / -2) + 12
    local y = (screen.height / 2) - 34
    screen.drawSprite("icons/pouch", x, y, 16, 16)
    screen.setLineWidth(3)
    screen.drawTextOutline("Z", x, y, 6, "#2a2d38")
    screen.drawText("Z", x, y, 6, 999)
    screen.setDrawAnchor(-1, 1)
    
    screen.drawTextOutline(
      "Dungeon #" + this.game.levelNumber,
      (screen.width / -2) + 24,
      (screen.height / 2) - 26,
      6, "#2a2d38"
    )
    
    screen.drawText(
      "Dungeon #" + this.game.levelNumber,
      (screen.width / -2) + 24,
      (screen.height / 2) - 26,
      6, 999
    )
    
    screen.drawTextOutline(
      "Balance: $" + this.displayBalance,
      (screen.width / -2) + 24,
      (screen.height / 2) - 36,
      6, "#2a2d38"
    )
    
    screen.drawText(
      "Balance: $" + this.displayBalance,
      (screen.width / -2) + 24,
      (screen.height / 2) - 36,
      6, 999
    )
    
    screen.setDrawAnchor(0, 0)
  end
  
  drawInventory = function() this.inventory.draw() end
  
  takeDamage = function(amount)
    if this.frozen or this.dead then return end
    if not amount or this.invincible or this.rollingFrames then return end
    
    this.lifeBar.change(-amount)
    
    local damageText = new global.Damage(this.game, -amount)
    damageText.x = this.x
    damageText.y = this.y
    damageText.text = "#de4040"
    damageText.line = "#290105"
    this.game.effects.push(damageText)
    
    audio.playSound("hit", 0.2)
    this.scale = [1.5, 0.5]
    this.hurtFrames = this.hurtDuration
    this.invincible = this.invincibleDuration
    this.game.camera.shake(1)
  end
  
  stopRolling = function()
    this.currentWobble = 0
    this.wobbleTime = 0
    this.rollingFrames = 0
    this.rollingDirection = [0, 0]
    after this.rollingCooldown seconds do this.canRoll = true end
  end
  
  die = function()
    if this.frozen or this.dead then return end
    this.stopRolling()
    this.dead = true
    
    global.lastScore = this.game.levelNumber
    if global.lastScore > global.highScore then
      global.lastHighScore = global.highScore
      global.highScore = global.lastScore
      storage.set("highscore", global.highScore)
    else global.lastHighScore = global.highScore end
    
    local deathTween = global.tweenService.createTween(
      this.light, "angleRange", this.light.angleRange, 0, 1,
      global.Easing.cubeOut
    )
    
    deathTween.completionHandler = function()
      local transition = function()
        global.sceneManager.setScene(global.SceneManager.GAME_OVER)
      end
      
      global.transition.requestTransition(transition, function() end, 1)
    end
  end
  
  equip = function(equipment)
    if this.frozen or this.dead then return end
    this.equipment = equipment
    
    local newFov = 0
    if not (equipment.type == "number") then newFov = equipment.fov end
    
    if this.lightTween then global.tweenService.removeTween(this.lightTween) end
    this.lightTween = global.tweenService.createTween(
      this.light, "angleRange", this.light.angleRange,
      newFov, 1, global.Easing.cubeOut
    )
  end
  
  lightsOut = function()
    if this.frozen or this.dead then return end
    
    this.stopRolling()
    this.frozen = true
    
    if this.lightTween then global.tweenService.removeTween(this.lightTween) end
    local lightsOutTween = global.tweenService.createTween(
      this.light, "angleRange", this.light.angleRange, 0, 1,
      global.Easing.cubeOut
    )
    
    lightsOutTween.completionHandler = function()
      local transition = function()
        global.sceneManager.scene.newLevel()
      end
      
      local transitionEnd = function()
        local game = global.sceneManager.scene
        local newFov = 0
        local equipment = game.player.equipment
        if not (equipment.type == "number") then newFov = equipment.fov end
        local lightsInTween = global.tweenService.createTween(
          game.player.light, "angleRange", 0, newFov, 1,
          global.Easing.cubeOut
        )
        
        lightsInTween.completionHandler = function()
          global.sceneManager.scene.player.frozen = false
        end
      end
      
      global.transition.requestTransition(transition, transitionEnd, 1)
    end
  end
  
  updateData = function()
    local visionMultiplier = (this.light.angleRangeMultiplier * 100) + "%"
    this.data = [
      ["Life Regeneration", "life", this.lifeBar.regeneration + "/sec"],
      ["Mana Regeneration", "mana", this.manaBar.regeneration + "/sec"],
      ["Acceleration", "speed", this.acceleration],
      ["Rolling Power", "power", this.rollingPower],
      ["Rolling Cooldown", "cooldown", this.rollingCooldown + " Seconds"],
      ["Vision Multiplier", "vision", visionMultiplier]
    ]
  end
end

