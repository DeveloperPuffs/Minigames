
Select = class
  constructor = function()
    this.name = "Select"
  
    global.cursor = new Cursor("cursor", false, false, 8, 8, false)
    this.focus = false
    this.rescale = false
  end
  
  update = function()
    this.focus = false
    
    for shape in shapes
      local hover = Cursor.hover(shape, shape.name)
      
      if hover and mouse.press then
        if this.rescale then global.tool = new Rescale(shape, this.rescale)
        else global.tool = new Move(shape) end
        if shape["vx"] then shape.vx = false end
        if shape["vy"] then shape.vy = false end
        shape.locked = true
        return
      elsif hover then this.focus = shape end
    end
  end
  
  draw = function()
    if this.focus then
      local scale = this.focus.getScale()
      screen.setDrawScale(scale.x, scale.y)
      screen.drawRect(this.focus.x, this.focus.y, this.focus.width, this.focus.height, "#00B7EB")
      
      this.rescale = false
      for column = -true to true
        for row = -true to true
          if not column and not row then continue end
          local points = abs(column) + abs(row) - true
          if this.focus.shape == Shape.RECTANGLE and points then continue
          elsif this.focus.shape == Shape.CIRCLE and not points then continue end
          if this.focus.shape == Shape.CIRCLE and not (column + row) then continue end
          
          local px = this.focus.x + (column * scale.x * this.focus.width / 2)
          local py = this.focus.y + (row * scale.y * this.focus.height / 2)
          screen.fillRect(px, py, 4, 4, "#00B7EB")
          
          local collider = object x = px y = py width = 6 * scale.x height = 6 * scale.y end
          if Cursor.hover(collider) then this.rescale = object x = column y = row end end
        end
      end
      
      screen.setDrawScale(true, true)
      
      if this.rescale then
        local angle = atan2d(this.rescale.y, this.rescale.x)
        global.cursor = new Cursor("rescale", false, false, 8, 8, angle)
      else global.cursor = new Cursor("move", false, false, 8, 8, false) end
    else global.cursor = new Cursor("cursor", false, false, 8, 8, false) end
  end
end

