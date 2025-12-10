
global.IngredientData = class
  constructor = function(data)
    this.name = data[0]
    this.sprite = data[1]
    this.width = data[2]
    this.height = data[3]
    this.size = data[4]
    this.description = data[5]
    this.affect = data[6]
    this.identifier = "ingredient"
  end
end

global.Ingredient = class
  PURPLE_GOO = new global.IngredientData([
    "Purple Goo", "ingredients/goo/purple", 8, 8, 8, (
      "+5% Mana Renegeration" +
      "\n+10 Total Mana" +
      "\nUsed in potions." +
      "\nChanges weapons's bullet colors."
    ), function(subject)
      if subject.identifier == "player" then
        subject.manaBar.regeneration *= 1.05
        subject.manaBar.total += 10
      elsif subject.identifier == "equipment" then
        subject.projectileColor = global.Projectile.PURPLE
      end
    end
  ])

  ORANGE_GOO = new global.IngredientData([
    "Orange Goo", "ingredients/goo/orange", 8, 8, 8, (
      "-5% Rolling Cooldown" +
      "\n+10% Rolling Power" +
      "\nUsed in potions." +
      "\nChanges weapons's bullet colors."
    ), function(subject)
      if subject.identifier == "player" then
        subject.rollingCooldown *= 0.95
        subject.rollingPower *= 1.1
      elsif subject.identifier == "equipment" then
        subject.projectileColor = global.Projectile.ORANGE
      end
    end
  ])

  BLUE_GOO = new global.IngredientData([
    "Blue Goo", "ingredients/goo/blue", 8, 8, 8, (
      "10% Acceleration" +
      "\nUsed in potions." +
      "\nChanges weapons's bullet colors."
    ), function(subject)
      if subject.identifier == "player" then
        subject.acceleration *= 1.1
      elsif subject.identifier == "equipment" then
        subject.projectileColor = global.Projectile.BLUE
      end
    end
  ])

  GREEN_GOO = new global.IngredientData([
    "Green Goo", "ingredients/goo/green", 8, 8, 8, (
      "+5% Health Regeneration" +
      "\n+10 Total Health" +
      "\nUsed in potions." +
      "\nChanges weapons's bullet colors."
    ), function(subject)
      if subject.identifier == "player" then
        subject.lifeBar.regeneration *= 1.05
        subject.lifeBar.total += 10
      elsif subject.identifier == "equipment" then
        subject.projectileColor = global.Projectile.GREEN
      end
    end
  ])
  
  BLACK_GOO = new global.IngredientData([
    "Black Goo", "ingredients/goo/black", 8, 8, 8, (
      "So this is what happens when you mix" +
      "\nall of the colors together???"
    ), function(subject)
      subject.projectileColor = global.Projectile.BLACK
    end
  ])

  PURPLE_SHARD = new global.IngredientData([
    "Purple Shard", "ingredients/shards/purple", 8, 8, 8, (
      "-10% Mana Usage" +
      "\n-20% Shooting Recoil" +
      "\nUsed to upgrade weapons."
    ), function(subject)
      subject.projectileMana = subject.projectileMana * 0.9
      subject.recoil = subject.recoil * 0.8
    end
  ])

  ORANGE_SHARD = new global.IngredientData([
    "Orange Shard", "ingredients/shards/orange", 8, 8, 8, (
      "+10 Strength" +
      "\n+20% Knockback" +
      "\nUsed to upgrade weapons."
    ), function(subject)
      subject.projectileDamage[0] += 10
      subject.projectileDamage[1] += 10
      subject.projectileKnockback *= 1.2
    end
  ])

  BLUE_SHARD = new global.IngredientData([
    "Blue Shard", "ingredients/shards/blue", 8, 8, 8, (
      "+10% Bullet Speed" +
      "\n-20% Shooting Cooldown" +
      "\nUsed to upgrade weapons."
    ), function(subject)
      subject.projectileSpeed *= 1.1
      subject.shootCooldown *= 0.8
    end
  ])

  GREEN_SHARD = new global.IngredientData([
    "Green Shard", "ingredients/shards/green", 8, 8, 8, (
      "\n+10% Weapon Vision" +
      "\nUsed to upgrade weapons."
    ), function(subject) subject.fov *= 1.1 end
  ])
  
  constructor = function(game, name)
    this.game = game
    this.identifier = "ingredient"
    this.data = this.getData(name)
    
    this.name = this.data.name
    this.sprite = this.data.sprite
    this.description = this.data.description
    this.affect = this.data.affect
    
    this.width = this.data.width
    this.height = this.data.height
    this.size = this.data.size
    
    this.x = 0
    this.y = 0
  end
  
  update = function()
    local player = this.game.player
    if (
      this.x < player.x + player.width and
      this.x + this.width > player.x and
      this.y < player.y + player.height and
      this.y + this.height > player.y
    ) then
      audio.playSound("pickup", 0.2)
      this.game.player.inventory.pouch.add(this)
      this.game.ingredients.removeElement(this)
    end
  end
  
  draw = function()
    screen.drawSprite(this.sprite, this.x, this.y, this.width, this.height)
  end
  
  getData = function(name)
    local a = [
      global.Ingredient.PURPLE_GOO,
      global.Ingredient.ORANGE_GOO,
      global.Ingredient.BLUE_GOO,
      global.Ingredient.GREEN_GOO,
      global.Ingredient.BLACK_GOO,
      global.Ingredient.PURPLE_SHARD,
      global.Ingredient.ORANGE_SHARD,
      global.Ingredient.BLUE_SHARD,
      global.Ingredient.GREEN_SHARD
    ]
    
    for b in a if b.name == name then return b end end
  end
end

  