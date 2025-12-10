
global.Interaction = class
  constructor = function(game, key, action = "Interact")
    this.game = game
    
    this.key = key
    this.action = action
    
    this.x = 0
    this.y = 0
    this.textSize = 4
  end
  
  update = function()
  end
  
  draw = function()
    local text = "Press '" + this.key + "' to " + this.action
    
    screen.setLineWidth(this.textSize / 2)
    screen.drawTextOutline(text, this.x, this.y, this.textSize, 0)
    screen.drawText(text, this.x, this.y, this.textSize, 999)
  end
end

