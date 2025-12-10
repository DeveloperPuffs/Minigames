
global.Stairs = class
  constructor = function(game, spot, flip)
    this.game = game
    this.spot = spot
    
    this.x = 0
    this.y = 0
    this.flip = flip
    this.width = 16
    this.height = 16
    
    this.interaction = new global.Interaction(this.game, "Q", "Advance")
    this.action = function() end
  end
  
  update = function()
    if this.canInteract(this.game.player) and keyboard.press.Q then
      this.action()
    end
  end
  
  draw = function()
    screen.setDrawScale(this.flip, 1)
    screen.drawSprite("dungeon/stairs", this.x, this.y, this.width, this.height)
    screen.setDrawScale(1, 1)
  end
  
  canInteract = function(player)
    return (
      player.column == this.spot[0] and (
        player.row == this.spot[1] or
        player.row == this.spot[1] + 1
      )
    )
  end
end

