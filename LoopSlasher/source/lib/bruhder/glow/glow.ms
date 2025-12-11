glow = class
  constructor = function(quality=200) //Bigger number = less pixelated
    this.imageSize = quality
    this.storedColor = object end
  end
  addColor = function(color)
    storedColor[color] = new Image(imageSize,imageSize,true)
    storedColor[color].setRadialGradient(0,0,imageSize/2,color,'transparent')
    storedColor[color].fillRect(0,0,imageSize,imageSize)
    return storedColor[color]
  end
  draw = function(x,y,size,color,opacity=1)
    local drawColor = if storedColor[color] then storedColor[color] else addColor(color) end
    screen.setAlpha(opacity)
    screen.drawImage(drawColor,x,y,size,size)
    screen.setAlpha(1)
  end
end