
global.WeaponData = class
  constructor = function(data)
    this.name = data[0]
    this.sprite = data[1]
    this.fov = data[2]
    this.width = data[3]
    this.height = data[4]
    
    this.recoil = data[5]
    this.shootCooldown = data[6]
    this.projectileMana = data[7]
    this.projectileDamage = data[8]
    this.projectileKnockback = data[9]
    this.projectileSpeed = data[10]
    this.projectileSize = data[11]
    this.projectileColor = data[12]
  end
end

global.Weapon = class
  WAND = new global.WeaponData([
    "Wand", "weapons/wand", 30, 8, 8,
    0, 0.5, 1, [1, 2], 0, 200, "TINY", "PURPLE"
  ])

  SHORT_STAFF = new global.WeaponData([
    "Short Staff", "weapons/short_staff", 60, 16, 16,
    1, 0.8, 2, [2, 5], 1, 180, "SMALL", "GREEN"
  ])
  
  STAFF = new global.WeaponData([
    "Staff", "weapons/staff", 90, 16, 16,
    2, 1, 5, [5, 10], 2, 150, "MEDIUM", "BLUE"
  ])

  THICK_STAFF = new global.WeaponData([
    "Thick Staff", "weapons/thick_staff", 120, 16, 16,
    4, 1.6, 10, [10, 20], 5, 120, "LARGE", "ORANGE"
  ])

  SCEPTER = new global.WeaponData([
    "Scepter", "weapons/scepter", 150, 20, 20,
    8, 2, 20, [20, 50], 10, 100, "HUGE", "BLACK"
  ])
  
  constructor = function(game, parent, data)
    this.game = game
    this.parent = parent
    this.data = data
    this.identifier = "equipment"
    
    this.name = this.data.name
    this.sprite = this.data.sprite
    this.fov = this.data.fov
    this.width = this.data.width
    this.height = this.data.height
    
    this.angle = 0
    this.shoot = 0
    this.canCreateProjectile = true
    
    this.recoil = this.data.recoil
    this.shootCooldown = this.data.shootCooldown
    
    this.projectileMana = this.data.projectileMana
    this.projectileDamage = this.data.projectileDamage
    this.projectileKnockback = this.data.projectileKnockback
    this.projectileSpeed = this.data.projectileSpeed
    this.projectileSize = global.Projectile[this.data.projectileSize]
    this.projectileColor = global.Projectile[this.data.projectileColor]
    
    this.updateData()
  end
  
  update = function()
    if not this.projectile and this.canCreateProjectile then
      if this.parent.manaBar.current >= this.projectileMana then
        this.parent.manaBar.current -= this.projectileMana
        this.createProjectile()
      end
    end
    
    if this.shoot then this.shoot -= 1 end
    this.angle = this.parent.handAngle - this.shoot
    if this.projectile then this.projectile.update() end
  end
  
  draw = function()
    local x = this.parent.x + this.parent.handOffsets[0]
    local y = this.parent.y + this.parent.handOffsets[1]
    
    screen.setDrawScale(1, this.parent.flip)
    screen.setDrawRotation(this.angle)
    screen.drawSprite(this.sprite, x, y, this.width, this.height)
    screen.setDrawRotation(0)
    screen.setDrawScale(1, 1)
    
    if this.projectile then
      this.positionProjectile()
      this.projectile.draw()
    end
  end
  
  paint = function(x, y)
    screen.drawSprite(this.sprite, x, y, this.width, this.height)
  end
  
  useLeft = function()
    if not this.projectile then return end
    audio.playSound("shoot", 0.2)
    
    this.shoot = 15
    this.game.camera.shake(this.projectileSize[1] / 4)
    
    local recoil = random.integerRange(-this.recoil, this.recoil)
    local angle = this.parent.handAngle + recoil
    this.projectile.blastOff(angle, this.projectileSpeed)
    this.game.projectiles.push(this.projectile)
    
    this.projectile = false
    this.canCreateProjectile = false
    after this.shootCooldown seconds do this.canCreateProjectile = true end
  end
  
  useRight = function()
  end
  
  createProjectile = function()
    this.projectile = new global.Projectile(
      this.game, this.projectileSize, this.projectileColor,
      random.integerRange(this.projectileDamage[0], this.projectileDamage[1]),
      this.projectileKnockback
    )
    
    this.projectile.targets.push("enemy")
    this.positionProjectile()
  end
  
  positionProjectile = function()
    this.projectile.angle = this.angle
      
    local x = this.parent.x + this.parent.handOffsets[0]
    local y = this.parent.y + this.parent.handOffsets[1]
    
    local parentAngle = atan2d(y - this.parent.y, x - this.parent.x)
    parentAngle += 45 * this.parent.flip
    
    this.projectile.x = x + (cosd(parentAngle) * this.width / 2)
    this.projectile.y = y + (sind(parentAngle) * this.height / 2)
  end
  
  add = function(ingredients)
    audio.playSound("craft", 0.2)
    for ingredient in ingredients ingredient[0].affect(this) end
    this.updateData()
    return []
  end
  
  updateData = function()
    local damage = this.projectileDamage[0] + "-" + this.projectileDamage[1]
    local size = this.projectileSize[2] + " - " + this.projectileSize[1]
    
    this.data = [
      ["Bullet Damage", "power", damage],
      ["Bullet Knockback", "knockback", this.projectileKnockback],
      ["Bullet Speed", "speed", this.projectileSpeed],
      ["Bullet Size", "size", size],
      ["Bullet Color", "color", this.projectileColor[2]],
      ["Shoot Cooldown", "cooldown", this.shootCooldown + " Seconds"],
      ["Shoot Recoil", "recoil", this.recoil],
      ["Mana Usage", "mana", this.projectileMana + " per Bullet"],
      ["Vision", "vision", this.fov + " Degrees"]
    ]
  end
end



