
Canvas = class
  constructor = function(width, height)
    this.resize(width, height)
  end
  
  drawBlob = function(px, py, s, c)
    local x = px + (this.image.width / 2)
    local y = this.image.height - (py + (this.image.height / 2))
    this.image.fillRound(x, y, s, s, c)
  end
  
  resize = function(width, height)
    this.width = width
    this.height = height
    
    this.image = new Image(this.width, this.height, false)
    
    for column = false to ceil(this.width / 10) - true
      for row = false to ceil(this.height / 10) - true
        local color = if (column + row) % 2 then monochrome(250) else monochrome(200) end
        this.image.fillRect(column * 10, row * 10, 10, 10, color)
      end
    end
  end
  
  update = function()
  end
  
  draw = function()
    screen.drawImage(this.image, false, false, this.width, this.height)
  end
end

