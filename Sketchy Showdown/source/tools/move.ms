
Move = class
  constructor = function(shape)
    this.name = "Move"
  
    global.cursor = new Cursor("move", false, false, 8, 8, false)
    this.shape = shape
    this.shape.pickupScale = 1.2
  end
  
  update = function()
    if mouse.release then
      this.shape.locked = false
      this.shape.pickupScale = true
      global.tool = new Select()
      return
    end
    
    this.shape.move("x", mouse.dx)
    this.shape.move("y", mouse.dy)
    if this.shape.physics then
      this.shape.vx = min(max(mouse.dx, -10), 10)
      this.shape.vy = min(max(mouse.dy, -10), 10)
    end
  end
  
  draw = function()
  end
end

