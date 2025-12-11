GameScene = class
  constructor = function()
    global.requestMusic("game", 1)

    this.bullets = []
    this.enemies = []
    this.player = new Player(this)
    this.player.x = random.number(-screen.width, screen.width) / 4
    this.player.y = random.number(-screen.height, screen.height) / 4
    this.player.flip = random.sign()
    
    this.shakes = []
    this.shakePosition = object
      x = 0
      y = 0
    end

    this.gameOver = false
    this.timeElapsed = 0
    this.secondsElapsed = 0
    this.timeTextScale = 1

    this.phase = 1
    this.spawnEnemyDelay = this.getEnemySpawnRate().maximum

    this.enemyData = object end
    this.enemyData["green_slime"] = object active = 0 kills = 0 end
    this.enemyData["orange_slime"] = object active = 0 kills = 0 end
    this.enemyData["blue_slime"] = object active = 0 kills = 0 end
    this.enemyData["purple_slime"] = object active = 0 kills = 0 end
    this.maximumEnemies = 20

    this.background = new Background()
    this.backgroundDrawRequest = object
      data = this
      layer = global.Layer.SURFACE_GROUND
      callback = function(data)
        data.background.draw()
      end
    end
    
    this.timerDrawRequest = object
      data = this
      layer = global.Layer.UI_OVERLAY
      callback = function(data)
        local x = screen.width / 2 - global.TILE_SIZE
        local y = screen.height / 2 - global.TILE_SIZE
        local text = data.formatTime(data.timeElapsed)

        screen.setDrawAnchor(1, 1)
        screen.setLineWidth(global.TILE_SIZE / 2)
        screen.setDrawScale(data.timeTextScale, data.timeTextScale)
        screen.drawTextOutline(text, x, y, global.TILE_SIZE, "black")
        screen.drawText(text, x, y, global.TILE_SIZE, "white")
        screen.resetDrawScale()
        screen.resetLineWidth()
        screen.resetDrawAnchor()
      end
    end
    
    this.explosionActivated = false
    this.explosionEmitter = Emitter.explosion(50)
    this.explosionEmitter.particlesPerSecond /= 5
    if global.graphicsMode == global.GRAPHICS_LOW then
      this.explosionEmitter.renderingMode = ParticleEmitter.NORMAL
    elsif global.graphicsMode == global.GRAPHICS_MEDIUM then
      this.explosionEmitter.renderingMode = ParticleEmitter.ANTI_ALIASED
    elsif global.graphicsMode == global.GRAPHICS_HIGH then
      this.explosionEmitter.renderingMode = ParticleEmitter.ALIASED
    end
    
    this.explosionDrawRequest = object 
      data = this
      layer = global.Layer.GAME_EXPLOSION
      callback = function(data)
        screen.drawEmitter(data.explosionEmitter)
      end
    end
    
    this.vignetteDrawRequest = object
      data = this
      layer = global.Layer.VIGNETTE_OVERLAY
      callback = function(data)
        screen.setAlpha(0.5)
        CRT(1000, 0, 0)
        screen.setAlpha(1)
      end
    end
    
    this.drawPool = []
  end
  
  activateExplosion = function(entity)
    if this.explosionActivated then
      return
    end
    
    this.explosionActivated = true
    this.explosionEmitter.position.x = entity.x
    this.explosionEmitter.position.y = entity.y
    this.explosionEmitter.trigger()
    
    after 0.5 seconds do
      this.player.handleCollision(entity, true)
    end
    
    audio.playSound("boom", 1)
  end
  
  formatTime = function(time)
    if time > 3600 then
      return ">1h"
    end
    
    local seconds = floor(time % 60)
    local minutes = floor(time / 60)
    
    local secondsString = "" + seconds
    if secondsString.length == 1 then
      secondsString = "0" + secondsString
    end
    
    local minutesString = "" + minutes
    if minutesString.length == 1 then
      minutesString = "0" + minutesString
    end
    
    return minutesString + ":" + secondsString
  end
  
  shake = function(power, decay)
    this.shakes.push(object
      power = power
      decay = decay
    end)
  end
  
  updateShakes = function(deltaTime)
    this.shakePosition.x = 0
    this.shakePosition.y = 0
    
    for shake in this.shakes
      shake.power -= shake.power * min(shake.decay * deltaTime, 1)
      if not shake.power then
        this.shakes.removeElement(shake)
        continue
      end
      
      local direction = random.number(0, 2 * PI)
      shakePosition.x = cos(direction) * shake.power
      shakePosition.y = sin(direction) * shake.power
    end
  end
  
  getEnemySpawnRate = function()
    return [
      object minimum = 2 maximum = 5 end,
      object minimum = 1 maximum = 2 end,
      object minimum = 0.5 maximum = 1 end,
      object minimum = 0.25 maximum = 0.5 end
    ][this.phase - 1]
  end
  
  getNextEnemyColor = function()
    local weights = []

    if this.phase == 1 then
      weights.push(object color = Slime.Color.GREEN weight = 80 end)
      weights.push(object color = Slime.Color.BLUE weight = 20 end)
    elsif this.phase == 2 then
      weights.push(object color = Slime.Color.GREEN weight = 40 end)
      weights.push(object color = Slime.Color.BLUE weight = 40 end)
      weights.push(object color = Slime.Color.PURPLE weight = 20 end)
    elsif this.phase == 3 then
      weights.push(object color = Slime.Color.GREEN weight = 10 end)
      weights.push(object color = Slime.Color.BLUE weight = 20 end)
      weights.push(object color = Slime.Color.PURPLE weight = 40 end)
      if this.enemyData[Slime.Color.ORANGE].active < 2 then
        weights.push(object color = Slime.Color.ORANGE weight = 30 end)
      end
    elsif this.phase == 4 then
      weights.push(object color = Slime.Color.BLUE weight = 10 end)
      weights.push(object color = Slime.Color.PURPLE weight = 30 end)
      if this.enemyData[Slime.Color.ORANGE].active < 3 then
        weights.push(object color = Slime.Color.ORANGE weight = 60 end)
      end
    end
    
    local totalWeight = 0
    for weight in weights
      totalWeight += weight.weight
    end
    
    for weight in weights
      weight.weight /= totalWeight
    end
    
    local counter = 0
    local selected = false
    local value = random.next()
    for weight in weights
      counter += weight.weight
      if counter >= value then
        selected = weight
        break
      end
    end
    
    return selected.color
  end
  
  spawnEnemies = function(deltaTime)
    local totalEnemies = 0
    for enemy in this.enemyData
      totalEnemies += this.enemyData[enemy].active
    end
    
    if totalEnemies >= this.maximumEnemies then
      return
    end

    this.spawnEnemyDelay -= deltaTime
    if this.spawnEnemyDelay <= 0 then
      local rate = this.getEnemySpawnRate()
      this.spawnEnemyDelay = random.number(rate.minimum, rate.maximum)
  
      local halfWidth = screen.width / 2
      local halfHeight = screen.height / 2
      local weight = screen.width / (screen.height + screen.width)
      
      local right = halfWidth + global.TILE_SIZE / 4
      local top = halfHeight + global.TILE_SIZE / 4
      local left = -right
      local bottom = -top
      
      local x = 0
      local y = 0
      while true
        if random.next() <= weight  then
          x = random.number(-halfWidth, halfWidth)
          y = random.choice([top, bottom])
        else
          y = random.number(-halfHeight, halfHeight)
          x = random.choice([left, right])
        end
    
        local dx = abs(x - player.x)
        if dx > halfWidth then
          dx = screen.width - dx
        end
    
        local dy = abs(y - player.y)
        if dy > halfHeight then
          dy = screen.height - dy
        end
    
        local distance = sqrt(pow(dx, 2) + pow(dy, 2))
        if distance >= 5 * global.TILE_SIZE then
          break
        end
      end

      local color = this.getNextEnemyColor()  
      local slime = new Slime(this, color, this.player)
      slime.x = x
      slime.y = y
  
      this.enemies.push(slime)
      this.enemyData[color].active += 1
    end
  end
  
  update = function(deltaTime)
    debug.print("Game Phase", this.phase)

    local lerp = function(a, b, t)
      return (1 - t) * a + t * b
    end

    this.timeTextScale = lerp(this.timeTextScale, 1, min(2 * deltaTime, 1))

    if not this.gameOver then
      this.spawnEnemies(deltaTime)
      this.timeElapsed += deltaTime
      while this.timeElapsed - (this.secondsElapsed + 1) > 0
        this.secondsElapsed += 1
        this.timeTextScale = 1.05
      end
      
      if this.timeElapsed >= 60 + 52 then
        this.phase = 4
      elsif this.timeElapsed >= 60 + 4 then
        this.phase = 3
      elsif this.timeElapsed >= 16 then
        this.phase = 2
      else
        this.phase = 1
      end
    end
    
    this.updateShakes(deltaTime)
    this.explosionEmitter.update(deltaTime)
  
    if not this.player.update(deltaTime) and not this.gameOver then
      this.gameOver = true
      
      local totalEnemyKills = 0
      local enemiesBreakdown = []
      for enemySprite in this.enemyData
        local data = this.enemyData[enemySprite]
        totalEnemyKills += data.kills
        enemiesBreakdown.push(object
          sprite = enemySprite
          kills = data.kills
        end)
      end

      local localGameStatistics = object
        timeText = this.formatTime(this.timeElapsed)
        trailsDrawn = this.player.trail.trailsDrawn
        enemyKills = totalEnemyKills
        enemiesBreakdown = enemiesBreakdown
      end

      local transitionAction = function()
        global.currentScene = new EndingScene(localGameStatistics)
      end

      global.transition.requestTransition(transitionAction, false, 2)
    end

    for bullet in this.bullets
      bullet.update(deltaTime)
    end
    
    for enemy in this.enemies
      if not enemy.update(deltaTime) then
        this.enemies.removeElement(enemy)
      end
    end
    
    this.updatePhysics()
  end
  
  draw = function()
    this.drawPool.push(this.backgroundDrawRequest)
    this.drawPool.push(this.explosionDrawRequest)
    this.drawPool.push(this.vignetteDrawRequest)
    this.drawPool.push(this.timerDrawRequest)
    
    for bullet in this.bullets
      bullet.draw()
    end

    for enemy in this.enemies
      enemy.draw()
    end
    
    this.player.draw()
    
    this.drawPool.sort(function(a, b)
      return a.layer - b.layer
    end)
  
    screen.setTranslation(this.shakePosition.x, this.shakePosition.y)
  
    for request in this.drawPool
      request.callback(request.data)
    end
  
    screen.resetTranslation()
    
    this.drawPool = []
  end
  
  updatePhysics = function()
    local entities = this.enemies.slice()
    entities.push(this.player)
  
    for a in entities
      for b in entities
        if a == b then
          continue
        end
  
        local dx = a.x - b.x
        local dy = a.y - b.y
        local distance = sqrt(pow(dx, 2) + pow(dy, 2))
        local overshoot = a.hitbox.radius + b.hitbox.radius - distance
        
        if overshoot > 0 then
          local mx = (overshoot + 1) * dx / distance
          local my = (overshoot + 1) * dy / distance
          a.x += mx
          a.y += my
  
          a.screenWrap()
          a.updateHitbox()
          
          if a.class.IDENTIFIER == Player.IDENTIFIER then
            a.handleCollision(b)
          end
          
          if b.class.IDENTIFIER == Player.IDENTIFIER then
            b.handleCollision(a)
          end
        end
      end
    end
  end
end