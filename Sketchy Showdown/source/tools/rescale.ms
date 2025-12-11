
Rescale = class
  constructor = function(shape, anchor)
    this.name = "Rescale"
    this.shape = shape
    this.anchor = anchor
  end
  
  update = function()
    if mouse.release or not this.shape then
      this.shape.locked = false
      global.tool = new Select()
      return
    end
    
    if not this.anchor.x or not this.anchor.y then
      if this.anchor.x then this.shape.rescale("x", mouse.dx, this.anchor.x) end
      if this.anchor.y then this.shape.rescale("y", mouse.dy, this.anchor.y) end
    else
      local original = object
        x = this.shape.x y = this.shape.y
        width = this.shape.width height = this.shape.height
      end
      
      local distance = (mouse.dx + mouse.dy) / 2
      local xScaled = this.shape.rescale("x", distance, this.anchor.x)
      local yScaled = this.shape.rescale("y", distance, this.anchor.y)
      if not xScaled or not yScaled then
        this.shape.x = original.x
        this.shape.y = original.y
        this.shape.width = original.width
        this.shape.height = original.height
      end
      
      this.shape.radius = (this.shape.width + this.shape.height) / 4
    end
  end
  
  draw = function()
  end
end

