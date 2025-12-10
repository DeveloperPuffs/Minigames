
global.Lantern = class
  sprite = "lantern"
  
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    this.identifier = "equipment"
    
    this.name = "Lantern"
    this.fov = 360
    this.width = 8
    this.height = 8
    
    this.shine = 0
    this.shineInterval = 2
    this.shineDelay = 90
    this.data = [
      ["Vision", "vision", this.fov + " Degrees"]
    ]
  end
  
  update = function()
    if this.shine then
      if this.shine > 8 * this.shineInterval then this.shine = 0
      else this.shine += 1 end
    elsif not (this.game.timer.frames % this.shineDelay) then
      this.shine += 1
    end
  end
  
  draw = function()
    local frames = global.sprites[global.Lantern.sprite].frames
    local frame = frames[floor(this.shine / this.shineInterval)]
    screen.drawSprite(
      frame, this.parent.x + this.parent.handOffsets[0],
      this.parent.y + this.parent.handOffsets[1] - (this.parent.handHeight / 2),
      this.width, this.height
    )
  end
  
  paint = function(x, y)
    local sprite = global.sprites[global.Lantern.sprite].frames[0]
    screen.drawSprite(sprite, x, y, this.width, this.height)
  end
  
  useLeft = function()
  end
  
  useRight = function()
  end
  
  add = function(ingredients)
    return ingredients
  end
end

