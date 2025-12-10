
global.EnemyData = class
  constructor = function(data)
    this.name = data[0]
    this.sprite = data[1]
    this.search = data[2]
    this.width = data[3]
    this.height = data[4]
    this.hitboxWidth = data[5]
    this.hitboxHeight = data[6]
    this.hitboxRadius = data[7]
    this.friction = data[8]
    this.acceleration = data[9]
    this.damage = data[10]
    this.knockback = data[11]
    this.life = data[12]
    this.coins = data[13]
    this.color = data[14]
    this.drops = data[15]
  end
end

global.Enemy = class
  PURPLE_SLIME = new global.EnemyData([
    "Purple Slime", "enemies/slimes/purple", 16, 16, 16, 12, 12, 8, 10, 4,
    [4, 8], 1, [8, 16], [10, 20], "#883eb3", [
      ["Purple Shard", 0.2],
      ["Purple Goo", 0.5]
    ]
  ])
  
  ORANGE_SLIME = new global.EnemyData([
    "Orange Slime", "enemies/slimes/orange", 8, 16, 16, 12, 12, 8, 12, 8,
    [8, 12], 4, [4, 8], [10, 20], "#ed7207", [
      ["Orange Shard", 0.2],
      ["Orange Goo", 0.5]
    ]
  ])

  GREEN_SLIME = new global.EnemyData([
    "Green Slime", "enemies/slimes/green", 12, 16, 16, 12, 12, 8, 10, 8,
    [2, 4], 1, [24, 32], [10, 20], "#25b346", [
      ["Green Shard", 0.2],
      ["Green Goo", 0.5]
    ]
  ])

  BLUE_SLIME = new global.EnemyData([
    "Blue Slime", "enemies/slimes/blue", 12, 16, 16, 12, 12, 8, 12, 16,
    [2, 4], 2, [8, 16], [10, 20], "#307cd9", [
      ["Blue Shard", 0.2],
      ["Blue Goo", 0.5]
    ]
  ])
  
  constructor = function(game, data)
    this.game = game
    this.name = data.name
    this.sprite = data.sprite
    this.color = data.color
    this.identifier = "enemy"
    
    this.path = false
    this.search = data.search
    
    this.x = 0
    this.y = 0
    this.flip = random.sign()
    this.width = data.width
    this.height = data.height
    this.scale = [1, 1]
    
    this.hitbox = new global.Hitbox()
    this.hitbox.rectangle.width = data.hitboxWidth
    this.hitbox.rectangle.height = data.hitboxHeight
    this.hitbox.circle.radius = data.hitboxRadius
    
    this.vx = 0
    this.vy = 0
    
    this.friction = data.friction
    this.acceleration = data.acceleration
    this.precision = 5
    
    this.damage = data.damage
    this.knockback = data.knockback
    
    this.bar = new global.EnemyBar(this.game, this)
    this.bar.total = random.integerRange(data.life[0], data.life[1])
    this.bar.total = round(this.bar.total * this.game.levelNumber / 5)
    this.bar.current = this.bar.total
    this.bar.regeneration = 1
    
    this.coins = random.integerRange(data.coins[0], data.coins[1])
    
    local dropped = []
    for item in data.drops
      if random.next() < item[1] then
        dropped.push(item[0])
        break
      end
    end
    
    this.drop = if dropped.length then random.choice(dropped) else false end
    
    this.hurtFrames = 0
    this.hurtDuration = 6
    
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
    
    this.currentWobble = 0
    this.wobbleSpeed = 10
    this.wobbleDegrees = 6
    this.wobbleTime = 0
    this.sine = function(t) sin(t) end
    this.cosine = function(t) sin(t) end
    this.wobbleWave = random.choice([this.sine, this.cosine])
  end
  
  update = function()
    this.trail.update()
    this.bar.update()
    this.scale[0] += ((1 - this.scale[0]) * 0.1)
    this.scale[1] += ((1 - this.scale[1]) * 0.1)
    this.flip = (this.game.player.x - this.x) / abs(this.game.player.x - this.x)
    
    this.path = global.findPath(
      this.game.dungeon, [this.x, this.y],
      [this.game.player.x, this.game.player.y - (this.game.player.height / 3)],
      this.search
    )
    
    if this.path then
      local position = this.path[if this.path.length > 1 then 1 else 0 end]
      local deltaTime = min(this.game.timer.deltaTime, 1 / this.friction)
        
      local horizontalDistance = ((this.path[1][0] + 0.5) * 16) - this.x
      local verticalDistance = ((this.path[1][1] + 0.5) * 16) - this.y
        
      local distance = sqrt(
        pow(horizontalDistance, 2) + pow(verticalDistance, 2)
      )
        
      this.vx += horizontalDistance * this.acceleration * deltaTime / distance
      this.vy += verticalDistance * this.acceleration * deltaTime / distance
      
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
    else
      this.steppingFrames = 0
      this.wobbleTime = 0
      this.currentWobble = 0
    end
    
    global.applyPhysics(this)
    if this.hurtFrames > 0 then this.hurtFrames -= 1 end
  end
  
  draw = function()
    this.trail.draw(this.game.camera.x, this.game.camera.y)
    screen.setDrawScale(this.scale[0] * this.flip, this.scale[1])
    screen.setDrawRotation(this.currentWobble)
    
    if this.hurtFrames then
      screen.drawSpriteWithColor(
        this.sprite, this.x, this.y, this.width, this.height, "white"
      )
    else
      screen.drawSprite(this.sprite, this.x, this.y, this.width, this.height)
    end
    
    screen.setDrawRotation(0)
    screen.setDrawScale(1, 1)
  end
  
  updateHitbox = function()
    this.hitbox.circle.x = this.x
    this.hitbox.circle.y = this.y
    this.hitbox.rectangle.x = this.x
    this.hitbox.rectangle.y = this.y
  end
  
  takeDamage = function(amount, damageColor)
    if not amount or this.hurtFrames then return end
    
    audio.playSound("hit", 0.2)
    this.bar.current = max(this.bar.current - amount, 0)
    
    local damageText = new global.Damage(this.game, amount)
    damageText.x = this.x
    damageText.y = this.y
    damageText.text = damageColor[0]
    damageText.line = damageColor[1]
    this.game.effects.push(damageText)

    if not this.bar.current then
      local coinScatter = function(count, data)
        if not count then return end
        
        local offset = random.integerRange(0, 360)
        local slice = 360 / count
        
        for index = 0 to count - 1
          local angle = (index * slice) + offset
          local coin = new global.Coin(this.game, this.x, this.y, angle, data)
          this.game.coins.push(coin)
        end
      end
      
      local c = this.coins
      local bronzeCoins = c % 10
      local silverCoins = (c / 10) % 10
      local goldCoins = max(floor(c - bronzeCoins - (10 * silverCoins)), 0)
      
      coinScatter(bronzeCoins, global.Coin.BRONZE)
      coinScatter(silverCoins, global.Coin.SILVER)
      coinScatter(goldCoins, global.Coin.GOLD)
      
      if this.drop then
        local ingredient = new global.Ingredient(this.game, this.drop)
        ingredient.x = this.x
        ingredient.y = this.y
        this.game.ingredients.push(ingredient)
      end
      
      this.game.camera.shake(4)
      this.game.entities.removeElement(this)
    else
      this.game.camera.shake(2)
      this.scale = [1.5, 0.5]
      this.hurtFrames = this.hurtDuration
    end
  end
  
  splatter = function(direction, speed)
    local sample = function(self, game, emitter)
      local particle = new global.Particle(game, emitter)
      
      particle.x = self.x
      particle.y = self.y
      
      local size = random.integerRange(8, 16)
      particle.width = size
      particle.height = size
      particle.color = self.color
      
      local angle = direction + random.integerRange(-60, 60)
      local power = speed * random.next()
      particle.vx = cosd(angle) * power
      particle.vy = sind(angle) * power
      
      particle.lifespan = 0.5
      return particle
    end
    
    local splatter = new global.Emitter(this.game, sample, this)
    splatter.infinite = false
    splatter.count = [8, 12]
    this.game.emitters.push(splatter)
  end
end

