
global.Projectile = class
  TINY = ["tiny", 4, "Tiny"]
  SMALL = ["small", 6, "Small"]
  MEDIUM = ["medium", 8, "Medium"]
  LARGE = ["large", 10, "Large"]
  HUGE = ["huge", 12, "Huge"]
  
  PURPLE = ["#ead7f7", "#36144d", "Purple"]
  ORANGE = ["#fff2c9", "#260602", "Orange"]
  BLUE = ["#c2ebfc", "#070e40", "Blue"]
  GREEN = ["#dcf7c6", "#021a0f", "Green"]
  BLACK = ["#4c5161", "black", "Black"]
  
  constructor = function(game, size, color, damage, knockback)
    this.game = game
    
    this.x = 0
    this.y = 0
    this.angle = 0
    
    this.vx = 0
    this.vy = 0
    
    this.size = size
    this.color = color
    this.torque = (random.next() * 12) - 6
    
    this.wobbleTime = 0
    this.scale = 1
    this.sine = function(t) sin(t) end
    this.cosine = function(t) sin(t) end
    this.wave = random.choice([this.sine, this.cosine])
    
    this.targets = []
    
    this.damage = damage
    this.knockback = knockback
    
    this.hitbox = new global.Hitbox()
    this.hitbox.rectangle.width = 1
    this.hitbox.rectangle.height = 1
    this.hitbox.circle.radius = this.size[1] / 2
    this.hit = []
    
    local sample = function(self, game, emitter)
      local particle = new global.Particle(game, emitter)
      
      local size = random.integerRange(self.size[1] / 2, self.size[1])
      particle.width = size
      particle.height = size
      particle.color = self.color[0]
      
      particle.lifespan = 0.6
      particle.x = self.x
      particle.y = self.y
      
      return particle
    end
    
    this.trail = new global.Emitter(this.game, sample, this)
    this.trail.interval = 4
    
    this.glow = new global.Glow(32)
    this.moving = false
  end
  
  update = function()
    this.wobbleTime += this.game.timer.deltaTime
    this.scale = 1 + (0.1 * this.wave(this.wobbleTime * 10))
    this.trail.update()
    
    if not this.moving then return end
    this.angle += this.torque
    this.x += this.vx * this.game.timer.deltaTime
    this.y += this.vy * this.game.timer.deltaTime
    this.updateHitbox()
    
    if global.tilemapCollision(this) then
      this.game.camera.shake(this.size[1] / 8)
      audio.playSound("boom", 0.05)
      this.destroy()
    elsif this.targets.length then
      for entity in this.game.entities
        if this.targets.contains(entity.identifier) then
          local horizontalDistance = entity.x - this.x
          local verticalDistance = entity.y - this.y
          local distance = sqrt(
            pow(horizontalDistance, 2) + 
            pow(verticalDistance, 2)
          )
          
          local maximumDistance = (
            (this.hitbox.circle.radius) + entity.hitbox.circle.radius
          )
          
          if distance <= maximumDistance then
            if this.hit.contains(entity) then continue
            else this.hit.push(entity) end
            
            entity.takeDamage(this.damage, this.color)
            entity.splatter(
              atan2d(verticalDistance, horizontalDistance),
              sqrt(pow(this.vx, 2) + pow(this.vy, 2))
            )
            
            global.applyImpulse(
              entity,
              this.knockback * horizontalDistance / distance,
              this.knockback * verticalDistance / distance
            )
          end
        end
      end
    end
  end
  
  draw = function()
    this.trail.draw(this.game.camera.x, this.game.camera.y)
    
    screen.setDrawRotation(this.angle)
    screen.setDrawScale(this.scale, this.scale)
    this.glow.draw(this.x, this.y, this.size[1] * 2, this.color[0], 1)
    
    screen.drawSpriteWithColor(
      "projectiles/fills/" + this.size[0],
      this.x, this.y,
      this.size[1], this.size[1],
      this.color[0]
    )
    
    screen.drawSpriteWithColor(
      "projectiles/outlines/" + this.size[0],
      this.x, this.y,
      this.size[1], this.size[1],
      this.color[1]
    )
    
    screen.setDrawScale(1, 1)
    screen.setDrawRotation(0)
  end
  
  destroy = function()
    local sample = function(self, game, emitter)
      local particle = new global.Particle(game, emitter)
      
      particle.x = self.x
      particle.y = self.y
      
      local size = random.integerRange(self.size[1], self.size[1] * 2)
      particle.width = size
      particle.height = size
      particle.color = self.color[0]
      
      local angle = atan2d(-self.vy, -self.vx) + random.integerRange(-60, 60)
      local power = sqrt(pow(self.vx, 2) + pow(self.vy, 2)) * random.next()
      particle.vx = cosd(angle) * power
      particle.vy = sind(angle) * power
      
      particle.lifespan = 0.5
      return particle
    end
    
    local splatter = new global.Emitter(this.game, sample, this)
    splatter.infinite = false
    splatter.count = [8, 12]
    this.game.emitters.push(splatter)
    
    this.game.projectiles.removeElement(this)
  end
  
  updateHitbox = function()
    this.hitbox.rectangle.x = this.x
    this.hitbox.rectangle.y = this.y - (this.size[1] / 2)
    this.hitbox.circle.x = this.x
    this.hitbox.circle.y = this.y
  end
  
  blastOff = function(angle, speed)
    this.angle = angle
    this.vx = cosd(angle) * speed
    this.vy = sind(angle) * speed
    this.moving = true
  end
end

