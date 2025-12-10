
global.Bar = class
  constructor = function(game, name, folderName, x, y)
    this.game = game
    this.name = name
    
    this.folderName = folderName
    
    this.current = 1
    this.total = 1
    this.scale = 1
    this.speed = 1
    
    this.x = x
    this.y = y
  end
  
  update = function()
    this.change(this.regeneration * this.game.timer.deltaTime)
    local difference = ((this.current / this.total) - this.scale)
    this.scale += difference * this.speed * this.game.timer.deltaTime
  end
  
  draw = function()
    screen.setTranslation(screen.width / -2, screen.height / 2)
    screen.setDrawAnchor(-1, 1)
    
    screen.setAlpha(0.2)
    screen.drawSprite(
      "bars/" + this.folderName + "/background",
      this.x, this.y, 64, 8
    )
    
    screen.setAlpha(1)
    
    screen.setDrawScale(this.scale, 1)
    screen.drawSprite(
      "bars/" + this.folderName + "/foreground",
      this.x, this.y, 64, 8
    )
    
    screen.setDrawScale(1, 1)
    screen.drawSprite(
      "bars/" + this.folderName + "/outline",
      this.x, this.y, 64, 8
    )
    
    local text = this.name + ": " + floor(this.current) + "/" + this.total
    screen.setLineWidth(2)
    screen.drawTextOutline(text, this.x + 68, this.y - 2, 4, "#2a2d38")
    screen.drawText(text, this.x + 68, this.y - 2, 4, 999)
    
    screen.setDrawAnchor(0, 0)
    screen.setTranslation(0, 0)
  end
  
  set = function(value)
    this.current = min(max(value, 0), this.total)
  end
  
  change = function(value)
    this.set(this.current + value)
  end
end

global.EnemyBar = class
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    
    this.current = 1
    this.total = 1
    this.scale = 1
    this.speed = 4
  end
  
  update = function()
    local difference = ((this.current / this.total) - this.scale)
    this.scale += difference * this.speed * this.game.timer.deltaTime
  end
  
  draw = function()
    local x = this.parent.x
    local y = this.parent.y + (this.parent.height / 2)
    
    screen.setAlpha(0.2)
    screen.drawSprite("bars/enemy/background", x, y, 16, 4)
    screen.setAlpha(1)
    
    screen.setDrawAnchor(-1, 0)
    screen.setDrawScale(this.scale, 1)
    screen.drawSprite("bars/enemy/foreground", x - 8, y, 16, 4)
    screen.setDrawScale(1, 1)
    screen.setDrawAnchor(0, 0)
    
    screen.drawSprite("bars/enemy/outline", x, y, 16, 4)
  end
end




