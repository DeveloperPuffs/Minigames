
Transition = class
  constructor = function()
    this.color = Palette.yellow
    this.reset()
  end
  
  reset = function()
    this.direction = random.next() > 0
    this.angle = random.nextInt(360)
    this.completionHandler = false
    this.tween = false
    this.time = 0
  end
  
  go = function(completionHandler)
    if this.tween then return end
    
    this.completionHandler = completionHandler
    this.tween = TweenService.createTween(this, "time", this.time, 2, 1, Tween.sineIn)
    this.tween.completionHandlers.push(function(tween)
      tween.parent.direction = not tween.parent.direction
      completionHandler()
      after 500 do
        tween.parent.tween = TweenService.createTween(tween.parent, "time", tween.parent.time, 0, 1, Tween.sineOut)
        tween.parent.tween.completionHandlers.push(function(innerTween) innerTween.parent.reset() end)
      end
    end)
  end
  
  draw = function()
    local columns = 10
    local rows = 10
    
    local sideLength = round(sqrt(pow(screen.width, 2) + pow(screen.height, 2)) / sqrt(pow(columns, 2) + pow(rows, 2)))
    
    local tileWidth = sideLength * 2
    local tileHeight = sideLength * sqrt(3)
    
    local width = (columns * sideLength) + ((columns + 1) * (sideLength / 2))
    local height = (rows + 0.5) * tileHeight
    
    screen.setRotation(this.angle)
    screen.setLineWidth(4)
    
    for row = 0 to rows - 1
      local rowNumber = if this.direction then row + 1 else (rows - (row + 1)) end
      local rowTime = min(max(this.time - (rowNumber / rows), 0), 1)
      if not rowTime then continue end
      
      for column = 0 to columns - 1
        local x = ((column + 0.5) * tileWidth) - (column * (sideLength / 2)) - (width / 2)
        local y = ((row + 0.5) * tileHeight) - (height / 2) + ((column % 2) * (tileHeight / 2))
        
        screen.fillFlatToppedHexagon(x, y, sideLength * rowTime, this.color)
      end
    end
    
    screen.setLineWidth(1)
    screen.setRotation(0)
  end
end

