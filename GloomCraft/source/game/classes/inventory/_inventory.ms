
global.Inventory = class
  IDLE = 1
  TABLE = 2
  SHOP = 3
  
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    this.state = global.Inventory.IDLE
    
    this.slots = new global.Slots(this.game, this)
    this.pouch = new global.Pouch(this.game, this)
    this.description = new global.Description(this.game, this)
    this.table = new global.Table(this.game, this)
    this.shop = new global.Shop(this.game, this)
    
    this.showing = false
    this.underlayTween = false
    this.underlayAlpha = 0
  end
  
  update = function()
    this.game.timer.frozen = this.showing
    
    this.slots.update()
    
    if this.showing then
      this.pouch.update()
      
      if this.state == global.Inventory.TABLE then
        this.table.update()
      elsif this.state == global.Inventory.SHOP then
        this.shop.update()
      end
      
      this.description.update()
    end
  end
  
  draw = function()
    if this.underlayAlpha then
      screen.setAlpha(this.underlayAlpha)
      screen.fillRect(0, 0, screen.width, screen.height, 0)
      screen.setAlpha(1)
      
      this.pouch.draw()
      
      if this.state == global.Inventory.TABLE then
        this.table.draw()
      elsif this.state == global.Inventory.SHOP then
        this.shop.draw()
      end
      
      this.description.draw()
    end
    
    this.slots.draw()
  end
  
  equip = function(equipment) this.parent.equip(equipment) end
  
  setVisibility = function(showing)
    if showing == this.showing then return end
    
    this.showing = showing
    if this.underlayTween then
      global.tweenService.removeTween(this.underlayTween)
    end
    
    local alpha = if this.showing then 0.6 else 0 end
    this.underlayTween = global.tweenService.createTween(
      this, "underlayAlpha", this.underlayAlpha,
      alpha, 0.5, global.Easing.sineInOut
    )
    
    this.pouch.setVisibility(this.showing)
    this.description.setVisibility(this.showing)
    this.table.setVisibility(this.showing)
    this.shop.setVisibility(this.showing)
  end
  
  toggleVisibility = function()
    this.setVisibility(not this.showing)
  end
end

