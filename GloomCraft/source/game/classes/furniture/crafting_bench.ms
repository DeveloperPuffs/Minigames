
global.CraftingBench = class
  constructor = function(game, spot)
    this.game = game
    this.spot = spot
    
    this.x = 0
    this.y = 0
    this.flip = random.sign()
    this.width = 32
    this.height = 16
    
    this.interaction = new global.Interaction(this.game, "E")
    this.variation = random.nextInt(4)
  end
  
  update = function()
    if this.canInteract(this.game.player) and keyboard.press.E then
      if this.game.player.inventory.showing then
        if this.game.player.inventory.state == global.Inventory.TABLE then
          this.game.player.inventory.setVisibility(false)
        end
      else
        this.game.player.inventory.state = global.Inventory.TABLE
        this.game.player.inventory.setVisibility(true)
      end
    end
  end
  
  draw = function()
    screen.setDrawScale(this.flip, 1)
    local sprite = "furniture/crafting_benches/" + this.variation
    screen.drawSprite(sprite, this.x, this.y, this.width, this.height)
    screen.setDrawScale(1, 1)
  end
  
  canInteract = function(player)
    local x = this.spot[0] - player.column
    return (x < 2 and x > -3 and abs(this.spot[1] - player.row) < 2)
  end
end

