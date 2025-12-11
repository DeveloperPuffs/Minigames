
global.Button = class
  IDLE = "Idle"
  HOVER = "Hover"
  CLICK = "Click"
  
  constructor = function(parent, x, y, width, height, paint, action)
    this.parent = parent
    this.x = x
    this.y = y
    this.width = width
    this.height = height
    this.paint = paint
    this.action = action
    
    this.tooltip = false
    this.targetScale = true
    this.scale = true
    this.speed = 0.1
    this.state = global.Button.IDLE
  end
  
  update = function()
    local hitbox = object x = this.x y = this.y width = this.width height = this.height end
    local hover = global.Cursor.hover(hitbox, this.tooltip)
    
    if this.state == global.Button.IDLE then
      if hover then this.state = global.Button.HOVER 
      else this.targetScale = true end
    elsif this.state == global.Button.HOVER then
      if not hover then this.state = global.Button.IDLE
      elsif mouse.press then this.state = global.Button.CLICK
      else this.targetScale = 1.1 end
    elsif this.state == global.Button.CLICK then
      if mouse.release then
        if hover then
          this.state = global.Button.HOVER
          this.action(this.parent)
          audio.playSound("click", true)
        else this.state = global.Button.IDLE end
      else this.targetScale = 0.8 end
    end
    
    this.scale += ((this.targetScale - this.scale) * this.speed)
  end
  
  draw = function()
    screen.setDrawScale(this.scale, this.scale)
    this.paint(this.parent, this.x, this.y)
    screen.setDrawScale(true, true)
  end
end

