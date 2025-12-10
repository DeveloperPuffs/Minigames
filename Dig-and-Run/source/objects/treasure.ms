
Treasure = class
  BURRIED = "Burried"
  IDLE = "Idle"
  OPENING = "Opening"
  OPENED = "Opened"
  
  constructor = function(island)
    this.island = island
    this.x = island.treasure[0]
    this.y = island.treasure[1]
  
    this.state = Treasure.BURRIED
    
    this.opening = 0
    this.chestFrame = 0
    
    this.crossDrawing = new Drawing(
      this, 3, function()
        screen.drawSprite("cross", this.parent.x, this.parent.y, 16, 16)
      end)
    
    this.shadowDrawing = new Drawing(
      this, 2, function()
        screen.drawSprite("shadow", this.parent.x, this.parent.y - 8, 16, 4)
      end)
    
    this.drawing = new Drawing(
      this, 7, function()
        local sprite = sprites["chest"].frames[this.parent.chestFrame]
        screen.drawSprite(sprite, this.parent.x, this.parent.y, 16, 16)
      end)
  end
  
  update = function()
    if this.state == Treasure.BURRIED then return end
    if this.opening and this.chestFrame == 5 then
      this.state = Treasure.OPENED
      this.opening.stop()
      this.opening = 0
      
      global.reward = new Reward()
    end
  end
  
  open = function()
    if this.state == Treasure.IDLE then
      this.opening = every 200 do this.chestFrame = min(this.chestFrame + 1, 5)  end
    end
  end
  
  dig = function(x, y)
    if sqrt(pow(this.x - x, 2) + pow(this.y - y, 2)) > 16 then return end
    
    if this.state == Treasure.BURRIED then
      this.state = Treasure.IDLE
    elsif this.state == Treasure.IDLE then
      this.open()
    end
  end
  
  draw = function()
    if this.state == Treasure.BURRIED then this.crossDrawing.enqueue()
    else
      this.shadowDrawing.enqueue()
      this.drawing.enqueue()
    end
  end
end




