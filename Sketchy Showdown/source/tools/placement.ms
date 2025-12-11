
Placement = class
  constructor = function()
    this.name = "Placement"
    
    global.cursor = new Cursor("place", false, false, 8, 8, false)
    this.shape = Rectangle
  end
  
  update = function()
    if mouse.press then
      local shape = new this.shape(mouse.x, mouse.y)
      if shape.collision() then shape.dispose() end
    end
  end
  
  set = function()
  end
  
  draw = function()
  end
end

