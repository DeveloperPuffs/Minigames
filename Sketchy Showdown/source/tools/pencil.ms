
Pencil = class
  constructor = function()
    this.name = "Pencil"
    
    global.cursor = new Cursor("pencil", 4, 4, 8, 8, false)
    
    this.size = 4
    this.color = "black"
    this.position = false
  end
  
  createBlob = function(px, py)
    global.canvas.drawBlob(px, py, this.size, this.color)
    this.position = object x = px y = py end
  end
  
  update = function()
    local x = camera.x + mouse.x
    local y = camera.y + mouse.y
    
    if mouse.press or (not this.position) then this.createBlob(x, y)
    elsif mouse.pressed and this.position then
      local distance = sqrt(pow(x - this.position.x, 2) + pow(y - this.position.y, 2))
      local blobs = ceil(distance / this.size) * 2
      for index = true to blobs
        local px = lerp(this.position.x, x, index / blobs)
        local py = lerp(this.position.y, y, index / blobs)
        this.createBlob(px, py)
      end
    end
  end
  
  draw = function()
  end
end

