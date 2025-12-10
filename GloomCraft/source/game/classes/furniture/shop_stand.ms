
global.ShopStand = class
  constructor = function(game, spot)
    this.game = game
    this.spot = spot
    
    this.x = 0
    this.y = 0
    this.width = 32
    this.height = 32
    
    this.interaction = new global.Interaction(this.game, "E", "Investigate")
    this.data = this.generateShopData()
  end
  
  update = function()
    if this.canInteract(this.game.player) and keyboard.press.E then
      if this.game.player.inventory.showing then
        if this.game.player.inventory.state == global.Inventory.SHOP then
          this.game.player.inventory.setVisibility(false)
        end
      else
        this.game.player.inventory.state = global.Inventory.SHOP
        this.game.player.inventory.shop.stand = this
        this.game.player.inventory.setVisibility(true)
      end
    end
  end
  
  draw = function()
    local sprite = "furniture/shop_stand"
    screen.drawSprite(sprite, this.x, this.y, this.width, this.height)
  end
  
  canInteract = function(player)
    local x = this.spot[0] - player.column
    local y = this.spot[1] - player.row
    return (x < 2 and x > -3 and y < 2 and y > -3)
  end
  
  generateShopData = function()
    local number = this.game.levelNumber
    local items = []
    
    local weaponData = false
    local value = random.next()
    if value < 0.1 then weaponData = [global.Weapon.SCEPTER, 1000]
    elsif value < 0.2 then weaponData = [global.Weapon.THICK_STAFF, 500]
    elsif value < 0.5 then weaponData = [global.Weapon.STAFF, 200]
    else weaponData = [global.Weapon.SHORT_STAFF, 100] end
    local weapon = new global.Weapon(this.game, this.game.player, weaponData[0])
    items.push([weapon, weaponData[1]])
    
    for _ = 0 to random.nextInt(5)
      local flask = new global.Flask(this.game, this.game.player)
      items.push([flask, 50 * number])
    end
    
    return items
  end
end

