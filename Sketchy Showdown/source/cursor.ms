
Cursor = class
  tooltip = false
  
  constructor = function(sprite, x, y, width, height, angle)
    this.sprite = sprite
    this.x = x
    this.y = y
    this.width = width
    this.height = height
    this.angle = angle
    
    this.tooltip = false
  end
  
  update = function()
  end
  
  draw = function()
    local x = mouse.x + this.x
    local y = mouse.y + this.y
    screen.setDrawRotation(this.angle)
    screen.drawSprite(this.sprite x, y, this.width, this.height)
    screen.setDrawRotation(false)
    
    if Cursor.tooltip then
      local width = screen.textWidth(Cursor.tooltip, 4) + 4
      screen.drawRect(mouse.x + (width / 2), mouse.y + 6, width, 8, false)
      screen.fillRect(mouse.x + (width / 2), mouse.y + 6, width, 8, 999)
      screen.drawText(Cursor.tooltip, mouse.x + (width / 2), mouse.y + 6, 4, false)
      Cursor.tooltip = false
    end
  end
end

Cursor.hover = function(item, tooltip = false)
  local verdict = (
    mouse.x >= item.x - (item.width / 2) and
    mouse.x <= item.x + (item.width / 2) and
    mouse.y >= item.y - (item.height / 2) and
    mouse.y <= item.y + (item.height / 2)
  )
    
  if verdict and tooltip then Cursor.tooltip = tooltip end
  return verdict
end
  
Cursor.click = function(item, tooltip = false) hover(item, tooltip) and mouse.press end
Cursor.clicking = function(item, tooltip = false) hover(item, tooltip) and mouse.pressed end
Cursor.release = function(item, tooltip = false) hover(item, tooltip) and mouse.release end
  
  