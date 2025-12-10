
global.Flask = class
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    this.identifier = "equipment"
    
    this.name = "Empty Flask"
    this.color = "#00000000"
    this.fov = 0
    this.width = 16
    this.height = 16
    this.ingredients = []
    
    this.drinking = false
    this.yeet = false
    this.angle = 0
    this.speed = 150
    this.x = 0
    this.y = 0
    
    this.hitbox = new global.Hitbox()
    this.hitbox.rectangle.width = 1
    this.hitbox.rectangle.height = 1
    this.hitbox.circle.radius = 8
    
    this.damage = 100
    this.knockback = 10
    
    this.data = [
      ["Vision", "vision", "0 Degrees"],
      ["Damage", "power", this.damage],
      ["Knockback", "knockback", this.knockback],
      ["Speed", "speed", this.speed]
    ]
  end
  
  update = function()
    if this.yeet then
      this.angle += this.game.timer.deltaTime * 90 * this.yeet / abs(this.yeet)
      this.x += cosd(this.yeet) * this.speed * this.game.timer.deltaTime
      this.y += sind(this.yeet) * this.speed * this.game.timer.deltaTime
      this.hitbox.rectangle.x = this.x
      this.hitbox.rectangle.y = this.y
      this.hitbox.circle.x = this.x
      this.hitbox.circle.y = this.y
      
      if global.tilemapCollision(this) then
        this.game.camera.shake(4)
        audio.playSound("boom", 0.05)
        this.destroy()
        return
      end
      
      for entity in this.game.entities
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
          entity.takeDamage(this.damage, ["white", "black"])
          entity.splatter(this.yeet, this.speed)
          global.applyImpulse(
            entity,
            this.knockback * horizontalDistance / distance,
            this.knockback * verticalDistance / distance
          )
              
          this.destroy()
          return
        end
      end
    end
  end
  
  draw = function()
    if this.yeet then
      screen.setDrawRotation(this.angle)
      this.paint(this.x, this.y)
    else
      local direction = this.parent.handOffsets[0]
      screen.setDrawRotation(this.drinking * (direction / abs(direction)) * 30)
      local x = this.parent.x + this.parent.handOffsets[0]
      local y = this.parent.y + this.parent.handOffsets[1] - 4
      this.paint(x, y)
    end
    
    screen.setDrawRotation(0)
  end
  
  paint = function(x, y)
    screen.setAlpha(0.8)
    screen.drawSpriteWithColor(
      "flask/fill", x, y, this.width, this.height, this.color
    )
    
    screen.setAlpha(1)
    screen.drawSprite("flask/outline", x, y, this.width, this.height)
  end
  
  useLeft = function()
    if this.drinking or this.yeet then return end
    this.drinking = true
    
    after 1 seconds do
      for ingredient in this.ingredients ingredient.affect(this.parent) end
      this.ingredients = []
      this.name = "Empty Flask"
      this.color = "#00000000"
      this.parent.updateData()
      this.drinking = false
      this.useRight()
    end
  end
  
  useRight = function()
    if this.drinking or this.yeet then return end
    this.yeet = this.parent.handAngle
    this.x = this.parent.x + this.parent.handOffsets[0]
    this.y = this.parent.y + this.parent.handOffsets[1] - 4
    this.parent.inventory.slots.remove(this)
    this.game.projectiles.push(this)
  end
  
  add = function(ingredients)
    local ingredientsLeft = [] + ingredients
    
    local sounded = false
    local failed = (this.name == "Putrid Potion")
    for ingredient in ingredientsLeft
      if failed then continue
      elsif ingredient[0].name.endsWith("Goo") then
        this.ingredients.push(ingredient[0])
        ingredientsLeft.removeElement(ingredient)
        if not sounded then
          audio.playSound("craft", 0.2)
          sounded = true
        end
        
        if this.ingredients.length > 1 then
          local failChance = random.floatRange(0.05, 0.1)
          if random.next() < failChance or ingredient[0].name == "Black Goo" then
            this.name = "Sludge"
            this.color = "#4a412a"
            failed = true
            continue
          end
        end
      end
    end
    
    if not failed and this.ingredients.length then
      this.name = "Potion"
      local r = random.next()
      local a = r * (1 / 3)
      local b = (r + 1) * (1 / 3)
      local c = (r + 2) * (1 / 3)
      local components = [a, b, c]
      random.shuffle(components)
      this.color = (
        "rgb(" +
        min(components[0] * 600, 255) + ", " +
        min(components[1] * 600, 255) + ", " +
        min(components[2] * 600, 255) + ")"
      )
    end
    
    return ingredientsLeft
  end
  
  destroy = function()
    local sample = function(self, game, emitter)
      local particle = new global.Particle(game, emitter)
      
      particle.x = self.x
      particle.y = self.y
      
      local size = random.integerRange(8, 16)
      particle.width = size
      particle.height = size
      particle.color = "white"
      particle.shape = global.Particle.RECTANGLE
      
      local angle = self.yeet + random.integerRange(-60, 60)
      local power = self.speed * random.next()
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
end

