
global.Cursor = class
  constructor = function()
    this.pointing = false
    this.tooltip = false
    mouse.x = false
    mouse.y = false
  end
  
  update = function()
    global.hideCursor()
    this.pointing = false
    this.tooltip = false
  end
  
  draw = function()
    local sprite = "cursor/" + if this.pointing then "pointing" else "idle" end
    screen.drawSprite(sprite, mouse.x + 6, mouse.y - 6, 12, 12)
    
    if this.tooltip then
      local width = screen.textWidth(this.tooltip[0], 6) + 8
      local x = mouse.x + (width / 2) + 6
      local y = mouse.y + 8
      
      screen.setLineWidth(1)
      screen.fillRect(x, y, width, 16, this.tooltip[1][1])
      screen.drawRect(x, y, width, 16, this.tooltip[1][0])
      screen.drawText(this.tooltip[0], x, y, 6, this.tooltip[1][0])
    end
  end

  hover = function(x, y, width, height, triggersClick = true)
    local verdict = (
      mouse.x >= x - (width / 2) and
      mouse.x <= x + (width / 2) and
      mouse.y >= y - (height / 2) and
      mouse.y <= y + (height / 2)
    )
    
    if verdict and triggersClick then this.pointing = true end
    return verdict
  end
  
  click = function(x, y, width, height)
    this.hover(x, y, width, height) and mouse.release
  end
end

