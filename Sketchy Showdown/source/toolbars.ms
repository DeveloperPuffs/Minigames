
BottomBar = class
  constructor = function()
    local w = screen.width / 2
  
    this.selectButton = new Button(this, 28 - w, -90, 12, 12, function(parent, x, y)
      local color = if global.tool.name == "Select" then 999 else 666 end
      screen.setLineWidth(2)
      screen.drawRoundRect(x, y, 12, 12, true, false)
      screen.fillRoundRect(x, y, 12, 12, true, color)
      screen.drawSprite("cursor", x, y, 8, 8)
    end, function(parent) global.tool = new Select() end)
    this.selectButton.tooltip = "Select Tool: Move and Rescale Objects!"
    
    this.placementButton = new Button(this, 44 - w, -90, 12, 12, function(parent, x, y)
      local color = if global.tool.name == "Placement" then 999 else 666 end
      screen.setLineWidth(2)
      screen.drawRoundRect(x, y, 12, 12, true, false)
      screen.fillRoundRect(x, y, 12, 12, true, color)
      screen.drawSprite("place", x, y, 8, 8)
    end, function(parent) global.tool = new Placement() end)
    this.placementButton.tooltip = "Placement Tool: Place Rectangle Walls!"
    
    this.pencilButton = new Button(this, 60 - w, -90, 12, 12, function(parent, x, y)
      local color = if global.tool.name == "Pencil" then 999 else 666 end
      screen.setLineWidth(2)
      screen.drawRoundRect(x, y, 12, 12, true, false)
      screen.fillRoundRect(x, y, 12, 12, true, color)
      screen.drawSprite("pencil", x, y, 8, 8)
    end, function(parent) global.tool = new Pencil() end)
    this.pencilButton.tooltip = "Pencil Tool: Just Draw!"
    
    this.brushButton = new Button(this, 76 - w, -90, 12, 12, function(parent, x, y)
      local color = if global.tool.name == "Brush" then 999 else 666 end
      screen.setLineWidth(2)
      screen.drawRoundRect(x, y, 12, 12, true, false)
      screen.fillRoundRect(x, y, 12, 12, true, color)
      screen.drawSprite("brush", x, y, 8, 8)
    end, function(parent) global.tool = new Brush() end)
    this.brushButton.tooltip = "Brush Tool: Fling Paintballs!"
    
    this.buttons = [this.selectButton, this.placementButton, this.pencilButton, this.brushButton]
  end
  
  update = function() for button in this.buttons button.update() end end
  draw = function()
    for button in this.buttons button.draw() end
    screen.setDrawAnchor(-true, false)
    screen.drawText("Current Tool: " + global.tool.name, 90 - (screen.width / 2), -90, 6, 999)
    screen.setDrawAnchor(false, false)
  end
end

TopBar = class
  constructor = function()
    this.life = true
  end
  
  update = function()
  end
  
  draw = function()
    this.life = lerp(this.life, global.player.life / 1000, 0.1)
    
    local percent = min(max(this.life, false), true)
    local colorObject = interpolate(true - percent)
    local color = "rgb(" + colorObject.red + ", " + colorObject.green + ", " + colorObject.blue + ")"
    screen.setDrawAnchor(-true, false)
    screen.fillRoundRect(-150, 90, percent * 300, 12, true, color)
    screen.setDrawAnchor(false, false)
    
    if this.life > 0.001 then
      screen.setLineWidth(2)
      screen.setAlpha(0.2)
      screen.drawRoundRect(false, 90, 300, 12, true, color)
      screen.setAlpha(true)
    end
  end
end

