
global.Button = class
  IDLE = "Idle"
  HOVER = "Hover"
  CLICK = "Click"
  
  constructor = function(x, y, width, height, paint, action)
    this.x = x
    this.y = y
    this.width = width
    this.height = height
    this.paint = paint
    this.action = action
    
    this.targetScale = 1
    this.scale = 1
    this.speed = 0.1
    this.state = global.Button.IDLE
  end
  
  update = function()
    local hover = global.cursor.hover(this.x, this.y, this.width, this.height)
    
    if this.state == global.Button.IDLE then
      if hover then this.state = global.Button.HOVER 
      else this.targetScale = 1 end
    elsif this.state == global.Button.HOVER then
      if not hover then this.state = global.Button.IDLE
      elsif mouse.press then this.state = global.Button.CLICK
      else this.targetScale = 1.1 end
    elsif this.state == global.Button.CLICK then
      if mouse.release then
        if hover then
          audio.playSound("click", 0.1)
          this.state = global.Button.HOVER
          this.action()
        else this.state = global.Button.IDLE end
      else this.targetScale = 0.8 end
    end
    
    this.scale += ((this.targetScale - this.scale) * this.speed)
  end
  
  draw = function()
    screen.setDrawScale(this.scale, this.scale)
    this.paint(x, y)
    screen.setDrawScale(1, 1)
  end
end

