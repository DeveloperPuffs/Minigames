
global.GameScene = class
  constructor = function(name)
    this.name = name
    
    audio.cancelBeeps()
    audio.playMusic("ost", 0.1, true)
    
    this.timer = new global.Timer()
    this.camera = new global.Camera()
    this.player = new global.Player(this)
    
    this.levelNumber = 0
    this.dungeonSize = 30
    this.newLevel()
    
    local lantern = new global.Lantern(this, this.player)
    this.player.inventory.slots.set(0, lantern)
    
    local wand = new global.Weapon(this, this.player, global.Weapon.WAND)
    this.player.inventory.slots.set(1, wand)
  end
  
  update = function()
    this.timer.tick()
    this.camera.update()
    
    this.startStairs.update()
    this.finishStairs.update()
    this.player.update()
    
    for projectile in this.projectiles projectile.update() end
    for effect in this.effects effect.update() end
    for emitter in this.emitters emitter.update() end
    
    local culledEntities = this.getCulledComponents(this.entities)
    for entity in culledEntities entity.update() end
    for item in this.getCulledComponents(this.furniture) item.update() end
    for coin in this.getCulledComponents(this.coins) coin.update() end
    for item in this.getCulledComponents(this.ingredients) item.update() end
    for coin in this.coins coin.update() end
    for ingredient in this.ingredients ingredient.update() end
    
    global.updatePhysics(culledEntities + this.player)
  end
  
  draw = function()
    this.camera.translate()
    
    local ground = this.dungeon.layers.ground
    screen.drawImage(ground,
      ground.width / 2,
      ground.height / 2,
      ground.width,
      ground.height
    )
    
    this.startStairs.draw()
    this.finishStairs.draw()
    
    local culledEntities = this.getCulledComponents(this.entities)
    local culledFurniture = this.getCulledComponents(this.furniture)
    local culledCoins = this.getCulledComponents(this.coins)
    local culledIngredients = this.getCulledComponents(this.ingredients)
    
    screen.setAlpha(0.6)
    for item in culledFurniture
      local y = item.y - (item.height / 2)
      local size = if item.width == 16 then "medium" else "large" end
      screen.drawSprite("shadows/" + size, item.x, y, item.width, 4)
    end
    
    for entity in culledEntities + this.player
      local y = entity.y - (entity.height / 2)
      screen.drawSprite("shadows/medium", entity.x, y, 16, 4)
    end
    
    for coin in culledCoins
      local y = coin.y - (coin.height / 2)
      screen.drawSprite("shadows/small", coin.x, y, 8, 4)
    end
    
    for ingredient in culledIngredients
      local y = ingredient.y - (ingredient.height / 2)
      local size = if ingredient.width == 8 then "small" else "medium" end
      screen.drawSprite("shadows/" + size, ingredient.x, y, ingredient.width, 4)
    end
    
    screen.setAlpha(1)
    for item in culledFurniture item.draw() end
    for coin in culledCoins coin.draw() end
    for ingredient in culledIngredients ingredient.draw() end
    
    local walls = this.dungeon.layers.walls
    screen.drawImage(walls,
      walls.width / 2,
      walls.height / 2,
      walls.width,
      walls.height
    )
    
    for entity in culledEntities entity.draw() end
    for entity in culledEntities entity.bar.draw() end
    for projectile in this.projectiles projectile.draw() end
    
    this.player.drawShadows()
    
    for emitter in this.emitters emitter.draw(this.camera.x, this.camera.y) end
    this.player.drawBody()
    
    for effect in this.effects effect.draw() end
    for item in culledFurniture
      if item.canInteract(this.player) then item.interaction.draw() end
    end
    
    if this.finishStairs.canInteract(this.player) then
      this.finishStairs.interaction.draw()
    end
    
    this.camera.transpose()
    this.player.drawStats()
    this.player.drawInventory()
  end
  
  newLevel = function()
    this.levelNumber += 1
    
    this.entities = []
    this.projectiles = []
    this.furniture = []
    this.coins = []
    this.ingredients = []
    this.effects = []
    this.emitters = []
    
    local size = this.dungeonSize
    local maximum = floor(size / 5)
    local density = round(pow(size, 2) / 30)
    this.dungeon = new global.Dungeon(size, size, 7, maximum, density)
    this.dungeon.layers = global.getLayers(this.dungeon)
    this.dungeon.surfaces = global.getSurfaces(this.dungeon)
    
    global.furnish(this)
    this.dungeon.colliderMap = global.getColliderMap(this.dungeon)
    
    local startFlip = random.sign()
    local startColumn = this.dungeon.start[0] + startFlip
    if not this.dungeon.colliderMap[this.dungeon.start[1]][startColumn] then
      startFlip = -startFlip
    end
    
    this.startStairs = new global.Stairs(this, this.dungeon.start, startFlip)
    this.startStairs.x = (this.dungeon.start[0] + 0.5) * 16
    this.startStairs.y = (this.dungeon.start[1] + 0.5) * 16
    this.startStairs.interaction = false
    
    this.player.x = (this.dungeon.start[0] + 0.5) * 16
    this.player.y = (this.dungeon.start[1] + 1) * 16
    this.player.flip = this.startStairs.flip
    this.camera.snap(player.x, player.y)
    this.player.updateHitbox()
    
    local finishFlip = random.sign()
    local finishColumn = this.dungeon.start[0] + finishFlip
    if not this.dungeon.colliderMap[this.dungeon.start[1]][finishColumn] then
      finishFlip = -finishFlip
    end
    
    this.finishStairs = new global.Stairs(this, this.dungeon.finish, finishFlip)
    this.finishStairs.x = (this.dungeon.finish[0] + 0.5) * 16
    this.finishStairs.y = (this.dungeon.finish[1] + 0.5) * 16
    this.finishStairs.interaction.x = this.finishStairs.x
    this.finishStairs.interaction.y = this.finishStairs.y + 8
    this.finishStairs.action = function() this.game.player.lightsOut() end
    
    this.dungeonSize += 5
  end
  
  getCulledComponents = function(components)
    local culledComponents = []
    
    local x = this.player.x
    local y = this.player.y
    for component in components
      if sqrt(pow(x - component.x, 2) + pow(y - component.y, 2)) <= 400 then
        culledComponents.push(component)
      end
    end
    
    return culledComponents
  end
end

